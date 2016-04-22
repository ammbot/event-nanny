defmodule EventNanny do
  use Application

  @sup EventNanny.Event.Supervisor

  import Application, only: [get_env: 3]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(GenEvent, [[name: event_monitor]]),
      supervisor(@sup, [[event_monitor: event_monitor]])
    ]

    opts = [strategy: :one_for_all, name: EventNanny.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:add_handler, _type, _args) do
    :event_nanny
    |> Application.get_env(:event_handler, [])
    |> Enum.map(fn{h,a} -> add_mon_handler(h,a) end)
    :ok
  end

  def add_mon_handler(handler, args) do
    Supervisor.start_child @sup, [[handler: handler, args: args]]
  end

  defp event_monitor do
    get_env(:event_nanny, :event_monitor, EventNanny.EventMonitor)
  end

end
