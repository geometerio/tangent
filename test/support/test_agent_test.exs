defmodule Test.Support.TestAgentTest do
  use ExUnit.Case, async: true
  use Tangent.Test

  alias Test.Support.Helpers
  alias Test.Support.TestAgent

  require Test.Support.Helpers

  ExUnit.Case.register_attribute(__MODULE__, :initial)

  setup context do
    initial = context.registered.initial || 0
    {:ok, agent} = start_supervised({TestAgent, [name: :"#{Helpers.uuid()}", initial: initial]})
    [agent: agent]
  end

  describe "current" do
    @initial 12
    test "exercises :get", %{agent: agent} do
      assert TestAgent.current(agent) == 12
    end
  end

  describe "put" do
    @initial 15
    test "exercises :update", %{agent: agent} do
      assert TestAgent.current(agent) == 15
      assert TestAgent.put(agent, 79) == :ok
      assert TestAgent.current(agent) == 79
    end
  end

  describe "increment" do
    @initial 10
    test "exercises :get_and_update", %{agent: agent} do
      assert TestAgent.current(agent) == 10
      assert TestAgent.increment(agent) == 11
      assert TestAgent.current(agent) == 11
    end
  end

  describe "decrement" do
    @initial 29
    test "exercises :get_and_update", %{agent: agent} do
      assert TestAgent.current(agent) == 29
      assert TestAgent.decrement(agent) == 28
      assert TestAgent.current(agent) == 28
    end
  end

  describe "async_put" do
    @initial 48
    test "exercises cast", %{agent: agent} do
      assert TestAgent.current(agent) == 48
      assert TestAgent.async_put(agent, 99) == :ok
      assert TestAgent.current(agent) == 48

      Helpers.retry(do: assert(TestAgent.current(agent) == 99))
    end
  end
end
