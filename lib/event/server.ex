defmodule EventNanny.Event.Server do
  use GenServer

  def start_link(default, args) do
    GenServer.start_link __MODULE__, default ++ args, []
  end

  def init(args) do
    args[:event_monitor]
    |> GenEvent.add_mon_handler(args[:handler], args[:handler_args])
    {:ok, nil}
  end

  def handle_info({:gen_event_EXIT, _handler, :normal}=msg, state) do
    {:stop, :shutdown, state}
  end
  def handle_info({:gen_event_EXIT, _handler, :shutdown}=msg, state) do
    Supervisor.stop(EventNanny.Event.Supervisor)
  end
  def handle_info({:gen_event_EXIT, _handler, _reason}=msg, state) do
    exit(:restart_me)
    {:noreply, state}
  end

end
