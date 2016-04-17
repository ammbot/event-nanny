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

    opts = [strategy: :one_for_one, name: EventNanny.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp event_monitor do
    get_env(:event_nanny, :event_monitor, EventNanny.EventMonitor)
  end

end
