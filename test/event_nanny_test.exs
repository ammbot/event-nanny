defmodule EventNannyTest do
  use ExUnit.Case

  import Process, only: [whereis: 1]

  test "should start GenEvent Monitor from config" do
    pid = whereis(MyEventMonitor)
    assert pid
    {:status, ^pid, {:module, GenEvent}, _} = :sys.get_status(pid)
  end

  test "should start EventNanny.Event.Supervisor" do
    assert whereis(EventNanny.Event.Supervisor)
    children = Supervisor.count_children(EventNanny.Event.Supervisor)
    assert children[:specs] == 1
  end

  test "should add_mon_handler from config" do
    children = Supervisor.count_children(EventNanny.Event.Supervisor)
    assert children[:active] == 1
    assert children[:workers] == 1
    assert GenEvent.which_handlers(MyEventMonitor) == [MyHandler]
    state = GenEvent.call(MyEventMonitor, MyHandler, :state)
    assert state == [arg1: 1, arg2: 2]
  end

  test "should restart when exit abnormally" do
    EventNanny.add_mon_handler {MyHandler, :restart_soon}, []
    handlers = GenEvent.which_handlers(MyEventMonitor)
    assert {MyHandler, :restart_soon} in handlers
    EventNanny.call {MyHandler, :restart_soon}, :kill
    :timer.sleep(500)
    handlers = GenEvent.which_handlers(MyEventMonitor)
    assert {MyHandler, :restart_soon} in handlers
  end

  test "should not restart when exit normally" do
    EventNanny.add_mon_handler {MyHandler, :die_soon}, []
    handlers = GenEvent.which_handlers(MyEventMonitor)
    assert {MyHandler, :die_soon} in handlers
    EventNanny.remove_handler {MyHandler, :die_soon}, []
    handlers = GenEvent.which_handlers(MyEventMonitor)
    refute {MyHandler, :die_soon} in handlers
  end

end
