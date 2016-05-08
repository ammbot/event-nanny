defmodule EventNanny.Event.Server do
  use GenServer

  import GenEvent, only: [add_mon_handler: 3]

  def start_link(default, args) do
    GenServer.start_link __MODULE__, default ++ args, []
  end

  def init(args) do
    case add_mon_handler(args[:event_monitor], args[:handler], args[:args]) do
      :ok -> {:ok, nil}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :unknown}
    end
  end

  def handle_info({:gen_event_EXIT, _handler, :normal}, state) do
    {:stop, :shutdown, state}
  end
  def handle_info({:gen_event_EXIT, _handler, :shutdown}, state) do
    Supervisor.stop(EventNanny.Event.Supervisor)
    {:stop, :shutdown, state}
  end
  def handle_info({:gen_event_EXIT, _handler, reason}, state) do
    {:stop, reason, state}
  end

end
