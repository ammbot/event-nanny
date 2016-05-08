defmodule EventNanny.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :event_nanny,
     version: @version,
     elixir: "~> 1.2",
     deps: deps,
     description: description,
     package: package,
     name: "event_nanny"]
  end

  def application do
    [applications: [:logger],
     start_phases: [{:add_handler, []}],
     mod: {EventNanny, []}]
  end

  defp deps do
    [
      {:inch_ex, "~> 0.5", only: :docs},
      {:earmark, "~> 0.2", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp description do
    """
    Nanny for GenEvent
    restart handler when it exit abnormally
    """
  end

  defp package do
    [
      maintainers: ["ammbot"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/ammbot/event-nanny.git"}
    ]
  end

end
