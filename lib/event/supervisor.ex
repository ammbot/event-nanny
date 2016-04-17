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

end
