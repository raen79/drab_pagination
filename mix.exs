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
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/raen79/drab_pagination"
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

  defp description() do
    "An elixir library to paginate ecto tables using drab. The library can, for example, be used to create infinity scrolling."
  end

  defp package() do
    [
      licenses: ["MIT"],
      name: "DrabPagination",
      maintainers: ["Eran Peer", "Ioana Surdu-Bob"],
      links: %{"GitHub" => "https://github.com/raen79/drab_pagination"}
    ]
  end
end
