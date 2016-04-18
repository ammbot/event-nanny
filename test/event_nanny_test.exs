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
    :timer.sleep(1000)
    children = Supervisor.count_children(EventNanny.Event.Supervisor)
    assert children[:active] == 1
    assert children[:workers] == 1
    handlers = GenEvent.which_handlers(MyEventMonitor)
    assert GenEvent.which_handlers(MyEventMonitor) == [MyHandler]
    state = GenEvent.call(MyEventMonitor, MyHandler, :state)
    assert state == [arg1: 1, arg2: 2]
  end

end
