# Tangent

[Documentation](https://hexdocs.pm/tangent)

Let your `Agent` calls go on a tangent.

<!-- MDOC !-->

Tangent provides functions and macros for bridging global `Agent` processes with `ExUnit` tests
configured to be `async: true`.

## Usage

`Tangent` can be used as a drop-in replacement for `Agent`:

```elixir
defmodule MyTangent do
  use Tangent

  def start_link(_), do: Tangent.start_link(fn -> 0 end, name: __MODULE__)
  def current(), do: Tangent.get(__MODULE__, & &1)
  def increment(), do: Tangent.get_and_update(__MODULE__, fn current -> {current + 1, current + 1} end)
  def decrement(), do: Tangent.get_and_update(__MODULE__, fn current -> {current - 1, current - 1} end)
end
```

When `Mix.env/0` is not equal to `:test`, this will compile to use `Agent` directly. In `:test` mode, this will
instead compile to use an interceptor process. By default this process will behave like an `Agent`, with a single
global dataset that will be accessed when callers access `Tangent`.

Test processes can register themselves as owners of dataset overloads via the `Tangent.Test.overload/1` macro.

If a process that traces its ancestry to the owner attempts to access the data, it will only get/update the
overloaded dataset specific to the owner.

```elixir
defmodule MyTangentTest do
  use ExUnit.Case, async: true
  use Tangent.Test

  setup do
    Tangent.Test.overload(MyTangent)
  end

  describe "increment" do
    test "increments the saved value" do
      assert MyTangent.current() == 0
      assert MyTangent.increment() == 1
      assert MyTangent.increment() == 2
      assert MyTangent.current() == 2

      spawn fn ->
        assert MyTangent.current() == 0
        assert MyTangent.increment() == 1
        assert MyTangent.current() == 1
      end

      Task.async fn ->
        assert MyTangent.current() == 2
      end
      |> Task.await()

      assert MyTangent.current() == 2
    end
  end
end
```

Note that the above works because `Task.async/1` spawns a process with an ancestry list, while `spawn/1` spawns
a process with no ancestry.

<!-- MDOC !-->
