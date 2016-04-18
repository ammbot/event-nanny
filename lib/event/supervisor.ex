defmodule EventNanny.Event.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link __MODULE__, args, [name: __MODULE__]
  end

  def init(args) do
    children = [worker(EventNanny.Event.Server, [args], restart: :transient)]
    opts = [strategy: :simple_one_for_one]
    supervise(children, opts)
  end

  def add_handler_from_config do
    :event_nanny
    |> Application.get_env(:event_handler, [])
    |> Enum.each(fn{h,a} -> EventNanny.add_mon_handler(h,a) end)
  end

end
