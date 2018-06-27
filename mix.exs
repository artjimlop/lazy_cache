defmodule LazyCache.MixProject do
  use Mix.Project

  @maintainers [
    "Arturo Jiménez"
  ]

  def project do
    [
      app: :lazy_cache,
      version: "0.1.1",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      maintainers: @maintainers,
      deps: deps(),
      description: description(),
      package: package(),
      # Docs
      name: "LazyCache",
      source_url: "https://github.com/artjimlop/lazy_cache",
      homepage_url: "https://github.com/artjimlop/lazy_cache",
      # The main page in the docs
      docs: [main: "LazyCache", extras: ["README.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, "~> 0.16", only: :dev, runtime: false}]
  end

  defp description() do
    "A memcached-like Elixir cache."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "lazy_cache",
      maintainers: @maintainers,
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["GNU General Public License v3.0"],
      links: %{"GitHub" => "https://github.com/artjimlop/lazy_cache"}
    ]
  end
end
