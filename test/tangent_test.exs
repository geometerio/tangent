defmodule TangentTest do
  use ExUnit.Case, async: true
  use Tangent.Test

  alias Test.Support.Helpers
  alias Test.Support.TestAgent

  require Test.Support.Helpers

  doctest Tangent

  ExUnit.Case.register_attribute(__MODULE__, :initial)

  setup context do
    initial = context.registered.initial || 0
    agent_name = :"#{Helpers.uuid()}"
    {:ok, agent} = start_supervised({TestAgent, [name: agent_name, initial: initial]})
    [name: agent_name, agent_pid: agent, test_pid: self()]
  end

  describe "get" do
    @initial 42
    test "gets global state by default", %{agent_pid: agent, name: name} do
      assert TestAgent.current(agent) == 42
      assert TestAgent.current(name) == 42
    end

    @initial 47
    test "initializes overloads with the initial value", %{agent_pid: agent, name: name} do
      assert TestAgent.current(agent) == 47
      Tangent.Test.overload(name)
      assert TestAgent.current(agent) == 47
    end
  end

  describe "update" do
    @initial 42
    test "updates global state by default", %{agent_pid: agent} do
      assert TestAgent.current(agent) == 42
      assert TestAgent.put(agent, 99) == :ok
      assert TestAgent.current(agent) == 99
    end

    @initial 12
    test "updates global state when referenced by name", %{agent_pid: agent, name: name} do
      assert TestAgent.current(agent) == 12
      assert TestAgent.put(name, 50) == :ok
      assert TestAgent.current(name) == 50
      assert TestAgent.current(agent) == 50
    end

    @initial 47
    test "accesses overloaded state after overload", %{agent_pid: agent, name: name, test_pid: test_pid} do
      Tangent.Test.overload(name)
      assert TestAgent.put(agent, 53) == :ok
      assert TestAgent.current(agent) == 53

      spawn(fn ->
        send(test_pid, {:from_spawn, TestAgent.current(agent)})
      end)

      Task.async(fn ->
        send(test_pid, {:from_child, TestAgent.current(agent)})
      end)

      assert_receive {:from_spawn, 47}
      assert_receive {:from_child, 53}
    end
  end

  describe "get_and_update" do
    @initial 42
    test "updates global state by default", %{agent_pid: agent} do
      assert TestAgent.current(agent) == 42
      assert TestAgent.increment(agent) == 43
      assert TestAgent.current(agent) == 43
    end

    @initial 12
    test "updates global state when referenced by name", %{agent_pid: agent, name: name} do
      assert TestAgent.current(agent) == 12
      assert TestAgent.increment(name) == 13
      assert TestAgent.current(name) == 13
      assert TestAgent.current(agent) == 13
    end

    @initial 47
    test "accesses overloaded state after overload", %{agent_pid: agent, name: name, test_pid: test_pid} do
      Tangent.Test.overload(name)
      assert TestAgent.increment(agent) == 48
      assert TestAgent.current(agent) == 48

      spawn(fn ->
        send(test_pid, {:from_spawn, TestAgent.current(agent)})
      end)

      Task.async(fn ->
        send(test_pid, {:from_child, TestAgent.current(agent)})
      end)

      assert_receive {:from_spawn, 47}
      assert_receive {:from_child, 48}
    end
  end

  describe "cast" do
    @initial 42
    test "updates global state by default", %{agent_pid: agent} do
      assert TestAgent.current(agent) == 42
      assert TestAgent.async_put(agent, 32) == :ok
      assert TestAgent.current(agent) == 42

      Helpers.retry(do: assert(TestAgent.current(agent) == 32))
    end

    @initial 12
    test "updates global state when referenced by name", %{agent_pid: agent, name: name} do
      assert TestAgent.current(agent) == 12
      assert TestAgent.async_put(name, 17) == :ok
      assert TestAgent.current(name) == 12

      Helpers.retry(do: assert(TestAgent.current(name) == 17))

      assert TestAgent.current(agent) == 17
    end

    @initial 12
    test "accesses overloaded state after overload", %{agent_pid: agent, name: name, test_pid: test_pid} do
      Tangent.Test.overload(name)
      assert TestAgent.current(agent) == 12
      assert TestAgent.async_put(name, 17) == :ok
      assert TestAgent.current(name) == 12

      Helpers.retry(do: assert(TestAgent.current(name) == 17))

      spawn(fn ->
        send(test_pid, {:from_spawn, TestAgent.current(agent)})
      end)

      Task.async(fn ->
        send(test_pid, {:from_child, TestAgent.current(agent)})
      end)

      assert_receive {:from_spawn, 12}
      assert_receive {:from_child, 17}
    end
  end
end
