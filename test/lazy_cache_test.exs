defmodule LazyCacheTest do
  use ExUnit.Case
  doctest LazyCache

  test "greets the world" do
    assert LazyCache.hello() == :world
  end
end
