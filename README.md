[![Build Status](https://travis-ci.org/artjimlop/lazy_cache.svg?branch=master)](https://travis-ci.org/artjimlop/lazy_cache)

# LazyCache

A memcached-like Elixir cache.

Before this library, caching data for a limited time was a a boring thing to do. Developers had to save the last time the data was stored, and then, check it every time the data was read. So, I decided to return the work to the open source community by writing this really simple cache, allowing developers to keep information for a limited time.

Shootout to # [QuitNow!](https://github.com/Fewlaps/quitnow-cache)'s cache. I wanted to do something for Elixir community and I took the idea from them. Also, I used it for some projects and works really great.

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lazy_cache` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lazy_cache, "~> 0.1.0"}
  ]
end
```

The sample
----------
```elixir
{:ok, PID} = LazyCache.start() # starts the cache and its process for auto-clearing expired elements

a_boolean = LazyCache.insert(key, value, keep_alive_in_milliseconds) # insert an element into the cache for a certain amount of time

a_boolean = LazyCache.insert(key, value) # this element is going to be stored forever!

a_boolean = LazyCache.delete(key) # delete this element

an_integer = LazyCache.size() # how many elements are in my cache?

a_boolean = LazyCache.clear() # delete everything!
```

The documentation can be found at [https://hexdocs.pm/lazy_cache](https://hexdocs.pm/lazy_cache).

## Contributing

Please, feel free to report any issue or contribute to the codebase.

Before creating your pull request, please run `mix test` to make sure nothing is broken!

## License

LazyCache source code is released under GNU General Public License v3.0. The generated contents, however, are under different licenses based on projects used to help render HTML, including CSS, JS, and other assets.

Check the [LICENSE](LICENSE) file for more information.
