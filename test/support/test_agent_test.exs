defmodule Test.Support.TestAgentTest do
  use ExUnit.Case, async: true
  use Tangent.Test

  alias Test.Support.Helpers
  alias Test.Support.TestAgent

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

  describe "inc" do
    @initial 15
    test "exercises :update", %{agent: agent} do
      assert TestAgent.current(agent) == 15
      assert TestAgent.inc(agent) == :ok
      assert TestAgent.current(agent) == 16
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
end
