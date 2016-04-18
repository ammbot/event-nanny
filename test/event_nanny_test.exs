defmodule EventNannyTest do
  use ExUnit.Case

  defmodule MyHandler do
    def init(args) do
      {:ok, args}
    end
    def handle_info(_, state) do
      {:ok, state}
    end
    def handle_call(:state, state) do
      {:ok, state, state}
    end
  end

  import Application, only: [start: 1, stop: 1, put_env: 3, delete_env: 2, get_env: 3]
  import Process, only: [whereis: 1]

  test "should start GenEvent Monitor from config" do
    stop(:event_nanny)
    put_env(:event_nanny, :event_monitor, MyEventMonitor)
    start(:event_nanny)
    pid = whereis(MyEventMonitor)
    assert pid
    {:status, ^pid, {:module, GenEvent}, _} = :sys.get_status(pid)
    stop(:event_nanny)
    delete_env(:event_nanny, :event_monitor)
    start(:event_nanny)
  end

  test "should start GenEvent Monitor with default if non config" do
    pid = whereis(EventNanny.EventMonitor)
    assert pid
    {:status, ^pid, {:module, GenEvent}, _} = :sys.get_status(pid)
  end

  test "should start EventNanny.Event.Supervisor" do
    assert whereis(EventNanny.Event.Supervisor)
    children = Supervisor.count_children(EventNanny.Event.Supervisor)
    assert children[:specs] == 1
  end

  test "should add_mon_handler from config" do
    put_env(:event_nanny, :event_handler, [{MyHandler, [arg1: 1, arg2: 2]}, {MyHandler, []}])
    :timer.sleep(1000)
    children = Supervisor.count_children(EventNanny.Event.Supervisor)
    assert children[:active] == 1
    assert children[:workers] == 1
    handlers = GenEvent.which_handlers(EventNanny.EventMonitor)
    assert GenEvent.which_handlers(EventNanny.EventMonitor) == [MyHandler]
    state = GenEvent.call(EventNanny.EventMonitor, MyHandler, :state)
    assert state == [arg1: 1, arg2: 2]
    delete_env(:event_nanny, :event_handler)
  end

end
