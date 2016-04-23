defmodule EventNanny do
  @moduledoc """
  Nanny for a GenEvent handler

  This Application will create the Supervisor and manager under the same Parent Supervisor and every handler will be take care by GenServer and restart it when exit abnormally.
  """
  use Application

  @sup EventNanny.Event.Supervisor

  import Application, only: [get_env: 3]

  #############
  # BEHAVIOUR #
  #############

  @doc """
  Starts the Nanny
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(GenEvent, [[name: event_monitor]]),
      supervisor(@sup, [[event_monitor: event_monitor]])
    ]
    opts = [strategy: :one_for_all, name: EventNanny.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Adds handler from app configuration
  """
  def start_phase(:add_handler, _type, _args) do
    :event_nanny
    |> Application.get_env(:event_handler, [])
    |> Enum.map(fn{h,a} -> add_mon_handler(h,a) end)
    :ok
  end

  #######
  # API #
  #######

  @doc """
  Adds a monitored event `handler`.
  """
  def add_mon_handler(handler, args) do
    Supervisor.start_child @sup, [[handler: handler, args: args]]
  end

  @doc """
  Removes an event `handler`.
  """
  def remove_handler(handler, args) do
    GenEvent.remove_handler event_monitor, handler, args
  end

  @doc """
  Replaces an old event `handler` with a new monitored one.
  """
  def swap_mon_handler(handler1, args1, handler2, args2) do
    GenEvent.swap_mon_handler event_monitor, handler1, args1, handler2, args2
  end

  @doc """
  Stops the `Nanny`.
  """
  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenEvent.stop event_monitor, reason, timeout
  end

  @doc """
  Sends a ack event notification.
  """
  def ack_notify(event) do
    GenEvent.ack_notify event_monitor, event
  end

  @doc """
  Makes a synchronous call the the event `handler`
  """
  def call(handler, request, timeout \\ 5000) do
    GenEvent.call event_monitor, handler, request, timeout
  end

  @doc """
  Returns a stream that consumes events.
  """
  def stream(timeout \\ :infinity) do
    GenEvent.stream event_monitor, timeout
  end

  @doc """
  Sends a sync event notification.
  """
  def sync_notify(event) do
    GenEvent.sync_notify event_monitor, event
  end

  @doc """
  Sends an event notification.
  """
  def notify(event) do
    GenEvent.notify event_monitor, event
  end

  @doc """
  Returns a list of all event `handlers`.
  """
  def which_handlers do
    GenEvent.which_handlers event_monitor
  end

  ############
  # INTERNAL #
  ############

  defp event_monitor do
    get_env(:event_nanny, :event_monitor, EventNanny.EventMonitor)
  end

end
