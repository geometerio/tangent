defmodule Test.Support.TestAgent do
  @moduledoc false
  use Tangent

  def start_link(name: name, initial: initial), do: Tangent.start_link(fn -> initial end, name: name)
  def current(agent), do: Tangent.get(agent, & &1)
  def put(agent, value), do: Tangent.update(agent, fn _ -> value end)
  def increment(agent), do: Tangent.get_and_update(agent, &{&1 + 1, &1 + 1})
  def decrement(agent), do: Tangent.get_and_update(agent, &{&1 - 1, &1 - 1})

  def async_put(agent, value) do
    caller = self()
    updater = fn _ -> value end

    Tangent.cast(agent, fn state ->
      Task.async(fn ->
        :timer.sleep(100)
        GenServer.call(agent, {:update, updater, caller}, 500)
        :timer.sleep(100)
      end)

      state
    end)
  end
end
