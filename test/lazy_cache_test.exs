defmodule LazyCacheTest do
  use ExUnit.Case, async: true

  def keep_alive_error() do
    "Keep Alive Time is not valid. Should be a positive Integer or :keep_alive_forever."
  end

  test "cache is empty when created" do
    LazyCache.start()
    assert LazyCache.size() == 0
  end

  test "should insert element in cache" do
    LazyCache.start()
    assert LazyCache.insert("key", "value", 1000) == true
  end

  test "should increment cache size when insert" do
    LazyCache.start()
    LazyCache.insert("key", "value", 1000)
    assert LazyCache.size() == 1
  end

  test "keep alive should be an Integer" do
    LazyCache.start()
    insert = LazyCache.insert("key", "value", "1000")
    assert insert == {:error, keep_alive_error()}
  end

  test "keep alive should be positive" do
    LazyCache.start()
    insert = LazyCache.insert("key", "value", 0)
    assert insert == {:error, keep_alive_error()}
  end

  test "keep alive cannot be nil" do
    LazyCache.start()
    insert = LazyCache.insert("key", "value", nil)
    assert insert == {:error, keep_alive_error()}
  end

  test "keep alive cannot be negative" do
    LazyCache.start()
    insert = LazyCache.insert("key", "value", -1)
    assert insert == {:error, keep_alive_error()}
  end

  test "should delete element from cache" do
    LazyCache.start()
    LazyCache.insert("key", "value", 1000)
    LazyCache.delete("key")
    assert LazyCache.size() == 0
  end

  test "ensure data exists when inserted" do
    LazyCache.start()
    LazyCache.insert("key", "value", 1000)
    assert [{"key", "value", _}] = LazyCache.lookup("key")
  end

  test "ensure data cannot be lookout when deleted" do
    LazyCache.start()
    LazyCache.insert("key", "value", 1000)
    LazyCache.delete("key")
    assert LazyCache.lookup("key") == []
  end

  test "ensure data is cleared correctly" do
    LazyCache.start()
    LazyCache.insert("key", "value", 1000)
    LazyCache.clear()
    assert LazyCache.lookup("key") == []
  end

  test "if there is data, cache is correctly cleared" do
    LazyCache.start()
    LazyCache.insert("key", "value", 1000)
    assert LazyCache.clear() == true
  end

  test "ensure data can be stored forever" do
    LazyCache.start()
    LazyCache.insert("key", "value")
    [data] = LazyCache.lookup("key")
    assert elem(data, 2) == :keep_alive_forever
  end
end
