defmodule SdvorLogger.Mixfile do
  use Mix.Project

  def project do
    [app: :sdvor_logger,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      env: [
        port:          5556,
        path_to_file:  "",
        filename:      "logfile.log",
        workers_count: 20,
        db_name:       "queue_msgs",
        hostname:      "MongoDB_Queue_msgs"
      ],
      mod: { SdvorLogger.ServerListener.Server, []},
      applications: [:logger, :mongodb, :poolboy],
      registered: [:sdvor_logger]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:poison, "~>2.0"},
     {:mongodb, ">=0.0.0"},
     {:poolboy, ">=0.0.0"}]
  end
end
