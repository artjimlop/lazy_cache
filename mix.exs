defmodule LazyCache.MixProject do
  use Mix.Project

  def project do
    [
      app: :lazy_cache,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

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
end
