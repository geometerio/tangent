# Overview

Let your `Agent` calls go on a tangent.

Tangent provides functions and macros for bridging global `Agent` processes with `ExUnit` tests
configured to be `async: true`.

## Installation

```elixir
def deps do
  [
    {:tangent, "~> 0.1.0"}
  ]
end
```

## Problem Statement

When using `Agent` processes to store state, it is common practices to start the processes from
an application's supervisor. Unit tests of the agent may use `ExUnit.Callbacks.start_supervised/2`
to test interactions in isolation, but when testing things like Phoenix controllers of Phoenix.LiveView,
cross-process interactions may mutate the state of the global agent, causing test pollution across
asynchronous processes.

## Usage

`Tangent` is intended to be a drop-in replacement for the `Agent` module that ships with Elixir.

```elixir
defmodule MyAgent do
  use Agent

  def start_link(_), do: Agent.start_link(fn -> 0 end, name: __MODULE__)
  def current(), do: Agent.get(__MODULE__, & &1)
  def increment(), do: Agent.get_and_update(__MODULE__, fn current -> {current + 1, current + 1} end)
  def decrement(), do: Agent.get_and_update(__MODULE__, fn current -> {current - 1, current - 1} end)
end
```

↓

```elixir
defmodule MyTangent do
  use Tangent

  def start_link(_), do: Tangent.start_link(fn -> 0 end, name: __MODULE__)
  def current(), do: Tangent.get(__MODULE__, & &1)
  def increment(), do: Tangent.get_and_update(__MODULE__, fn current -> {current + 1, current + 1} end)
  def decrement(), do: Tangent.get_and_update(__MODULE__, fn current -> {current - 1, current - 1} end)
end
```

When code is compiled in `Mix.env() == :test`, the underlying agent is swapped out for an interceptor.
This interceptor keeps data in a global dataset, so by default it will act like a global `Agent`.
Test processes can `use Tangent.Test` to register themselves as the parent of overloaded datasets. After overloading
an agent, any child process of the test will access the overloaded, rather than the global, dataset.

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
      assert MyTangent.current() == 1
    end
  end
end

defmodule MyOtherTangentTest do
  use ExUnit.Case, async: true
  use Tangent.Test

  setup do
    Tangent.Test.overload(MyTangent)
  end

  describe "decrement" do
    test "decrements the saved value" do
      assert MyTangent.current() == 0
      assert MyTangent.decrement() == -1
      assert MyTangent.current() == -1
    end
  end
end
```

<!-- MDOC !-->
