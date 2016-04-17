defmodule EventNannyTest do
  use ExUnit.Case

  test "should start GenEvent Monitor from config" do
    Application.stop(:event_nanny)
    Application.put_env(:event_nanny, :event_monitor, MyEventMonitor)
    Application.start(:event_nanny)
    pid = Process.whereis(MyEventMonitor)
    assert pid
    {:status, ^pid, {:module, GenEvent}, _} = :sys.get_status(pid)
    Application.stop(:event_nanny)
    Application.delete_env(:event_nanny, :event_monitor)
    Application.start(:event_nanny)
  end

  test "should start GenEvent Monitor with default if non config" do
    pid = Process.whereis(EventNanny.EventMonitor)
    assert pid
    {:status, ^pid, {:module, GenEvent}, _} = :sys.get_status(pid)
  end

  test "should start EventNanny.Event.Supervisor" do
    assert Process.whereis(EventNanny.Event.Supervisor)
    children = Supervisor.count_children(EventNanny.Event.Supervisor)
    assert children[:specs] == 1
  end

end
