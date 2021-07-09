defmodule Tangent.Agent.Passthrough do
  @moduledoc """
  Passes through all calls to Agent.
  """

  use Agent

  @type on_start() :: Agent.on_start()
  @type agent() :: Agent.agent()
  @type state() :: term()

  @spec start_link((() -> term()), GenServer.options()) :: on_start()
  def start_link(fun, options \\ []) when is_function(fun) do
    IO.puts("starting passthrough")
    Agent.start_link(fun, options)
  end

  @spec start_link(module, atom, [any], GenServer.options()) :: on_start
  def start_link(module, fun, args, options \\ []) do
    Agent.start_link(module, fun, args, options)
  end

  @spec get(agent(), getter :: (state() -> a), timeout :: integer()) :: a when a: var
  def get(agent, getter, timeout \\ 5000) when is_function(getter) do
    Agent.get(agent, getter, timeout)
  end

  @spec get(agent, module, atom, [term], timeout) :: any
  def get(agent, module, fun, args, timeout \\ 5000) do
    Agent.get(agent, module, fun, args, timeout)
  end

  @spec get_and_update(agent(), (state() -> {a, state}), timeout) :: a when a: var
  def get_and_update(agent, fun, timeout \\ 5000) when is_function(fun, 1) do
    Agent.get_and_update(agent, fun, timeout)
  end

  @spec get_and_update(agent, module, atom, [term], timeout) :: any
  def get_and_update(agent, module, fun, args, timeout \\ 5000) do
    Agent.get_and_update(agent, module, fun, args, timeout)
  end

  @spec update(agent, (state -> state), timeout) :: :ok
  def update(agent, fun, timeout \\ 5000) when is_function(fun, 1) do
    Agent.update(agent, fun, timeout)
  end

  @spec update(agent, module, atom, [term], timeout) :: :ok
  def update(agent, module, fun, args, timeout \\ 5000) do
    Agent.update(agent, module, fun, args, timeout)
  end

  @spec cast(agent, (state -> state)) :: :ok
  def cast(agent, fun) when is_function(fun, 1) do
    Agent.cast(agent, fun)
  end

  @spec cast(agent, module, atom, [term]) :: :ok
  def cast(agent, module, fun, args) do
    Agent.cast(agent, module, fun, args)
  end

  @spec stop(agent, reason :: term, timeout) :: :ok
  def stop(agent, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(agent, reason, timeout)
  end
end
