defmodule Test.Support.TestAgent do
  @moduledoc false
  use Tangent

  def start_link(name: name, initial: initial), do: Tangent.start_link(fn -> initial end, name: name)
  def current(agent), do: Tangent.get(agent, & &1)
  def inc(agent), do: Tangent.update(agent, &(&1 + 1))
  def increment(agent), do: Tangent.get_and_update(agent, &{&1 + 1, &1 + 1})
  def decrement(agent), do: Tangent.get_and_update(agent, &{&1 - 1, &1 - 1})
end
