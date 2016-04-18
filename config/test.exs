use Mix.Config

config :event_nanny,
  event_monitor: MyEventMonitor,
  event_handler: [
    {MyHandler, [arg1: 1, arg2: 2]},
    {MyHandler, []}
  ]

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
