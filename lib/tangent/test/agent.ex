defmodule Tangent.Test.Agent do
  @moduledoc """
  An agent which must be started in the test environment before Tangent is used in
  an application.

  ## `test_helper.exs`

  ```elixir
  {:ok, _agent} = Tangent.Test.Agent.start()
  ```
  """

  @spec start_link(module(), (() -> term())) :: GenServer.on_start()
  def start_link(agent_module, fun) when is_function(fun, 0) do
    do_start(agent_module, fun)
  end

  def start_link(agent_module, module, fun, args) do
    do_start(agent_module, {module, fun, args})
  end

  defp do_start(agent_module, initial) do
    case GenServer.whereis(agent_module) do
      nil -> GenServer.start(Tangent.Test.Server, [initial: initial], name: agent_module)
      server -> {:ok, server}
    end
  end

  @spec ensure_started!(module()) :: pid() | no_return()
  def ensure_started!(agent_module) do
    GenServer.whereis(agent_module)
    |> case do
      pid when is_pid(pid) -> pid
      nil -> raise "Tangent.Test.Agent must be started for #{agent_module}"
    end
  end

  def get(agent, fun, timeout, caller),
    do: GenServer.call(agent, {:get, fun, caller}, timeout)

  def get(agent, module, fun, args, timeout, caller),
    do: GenServer.call(agent, {:get, {module, fun, args}, caller}, timeout)

  def get_and_update(agent, fun, timeout, caller),
    do: GenServer.call(agent, {:get_and_update, fun, caller}, timeout)

  def get_and_update(agent, module, fun, args, timeout, caller),
    do: GenServer.call(agent, {:get_and_update, {module, fun, args}, caller}, timeout)

  def update(agent, fun, timeout, caller),
    do: GenServer.call(agent, {:update, fun, caller}, timeout)

  def update(agent, module, fun, args, timeout, caller),
    do: GenServer.call(agent, {:update, {module, fun, args}, caller}, timeout)

  def cast(agent, fun, caller),
    do: GenServer.cast(agent, {:cast, fun, caller})

  def cast(agent, module, fun, args, caller),
    do: GenServer.cast(agent, {:cast, {module, fun, args}, caller})
end
