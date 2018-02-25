defmodule DrabPagination.Mixfile do
  use Mix.Project

  def project do
    [
      app: :drab_pagination,
      version: "0.1.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.5.2",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :drab]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:drab, "~> 0.6.1"},
      {:ecto, "~> 2.1"}
    ]
  end
end
