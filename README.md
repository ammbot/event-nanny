# EventNanny

Nanny for a GenEvent handler

This Application will create the Supervisor and manager under the same Parent Supervisor and every handler will be take care by GenServer and restart it when exit abnormally.

## Installation

First, add EventNanny to your mix.exs dependencies:

```elixir
def deps do
  [{:event_nanny, "~> 0.1.1"}]
end
```

and run `mix deps.get`. Now, list the `:event_nanny` application as your application dependency:

```elixir
def application do
  [applications: [:event_nanny]]
end
```

## Basic Usage

Instead of adding a handler with `GenEvent.add_handler(manager, handler, args)` or
`GenEvent.add_mon_handler(manager, handler, args)` just use

```elixir
EventNanny.add_mon_handler(handler, args)
```

## Configuration

You can named your `manager` or add `handle` when nanny started

```elixir
config :event_nanny,
  event_monitor: MyEventMonitor,
  event_handler: [
    {MyHandler, [arg1: 1, arg2: 2]},
    {MyHandler, []}
  ]
```
