defmodule Tangent.Test.Agent do
  @moduledoc """
  An agent which will be started in the test environment in place of `Agent`.
  """

  @doc """
  Registers the `owner` process as the parent of any agent overloads. After registering
  an overload, any process that is a child of the caller will access a segmented dataset
  when accessing the agent.
  """
  @spec register(agent :: Tangent.agent(), owner :: pid()) :: :ok
  def register(agent, owner) do
    Process.put(:__tangent_overload__, owner)
    GenServer.call(agent, {:register, owner})
  end

  @doc false
  @spec start_link(module(), (() -> term()), GenServer.options()) :: GenServer.on_start()
  def start_link(agent_module, fun, options \\ []) when is_function(fun, 0) do
    do_start(agent_module, fun, options)
  end

  @doc false
  @spec start_link(module(), module(), atom(), [any], GenServer.options()) :: GenServer.on_start()
  def start_link(agent_module, module, fun, args, options \\ []) do
    do_start(agent_module, {module, fun, args}, options)
  end

  defp do_start(agent_module, initial, options) do
    process = Keyword.get(options, :name, agent_module)

    case GenServer.whereis(process) do
      nil -> GenServer.start(Tangent.Test.Server, [initial: initial], options)
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

  @doc false
  def get(agent, fun, timeout, caller),
    do: GenServer.call(agent, {:get, fun, caller}, timeout)

  @doc false
  def get(agent, module, fun, args, timeout, caller),
    do: GenServer.call(agent, {:get, {module, fun, args}, caller}, timeout)

  @doc false
  def get_and_update(agent, fun, timeout, caller),
    do: GenServer.call(agent, {:get_and_update, fun, caller}, timeout)

  @doc false
  def get_and_update(agent, module, fun, args, timeout, caller),
    do: GenServer.call(agent, {:get_and_update, {module, fun, args}, caller}, timeout)

  @doc false
  def update(agent, fun, timeout, caller),
    do: GenServer.call(agent, {:update, fun, caller}, timeout)

  @doc false
  def update(agent, module, fun, args, timeout, caller),
    do: GenServer.call(agent, {:update, {module, fun, args}, caller}, timeout)

  @doc false
  def cast(agent, fun, caller),
    do: GenServer.cast(agent, {:cast, fun, caller})

  @doc false
  def cast(agent, module, fun, args, caller),
    do: GenServer.cast(agent, {:cast, {module, fun, args}, caller})
end
