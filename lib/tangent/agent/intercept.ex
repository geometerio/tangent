defmodule Tangent.Agent.Intercept do
  @moduledoc false

  @type on_start() :: Tangent.on_start()
  @type agent() :: Tangent.agent()
  @type state() :: term()

  @spec start_link(module(), (() -> term()), GenServer.options()) :: Macro.t()
  def start_link(caller_module, fun, _options) when is_function(fun, 0) do
    Tangent.Test.Agent.start_link(caller_module, fun)
  end

  @spec start_link(module(), module(), atom(), [any()], GenServer.options()) :: Macro.t()
  def start_link(caller_module, module, fun, args, _options) do
    Tangent.Test.Agent.start_link(caller_module, module, fun, args)
  end

  @spec get(agent(), getter :: (state() -> a), timeout :: integer()) :: a when a: var
  def get(agent, getter, timeout) when is_function(getter) do
    Tangent.Test.Agent.get(agent, getter, timeout, self())
  end

  @spec get(agent(), module(), atom(), [term()], timeout) :: any()
  def get(agent, module, fun, args, timeout) do
    Tangent.Test.Agent.get(agent, module, fun, args, timeout, self())
  end

  @spec get_and_update(agent(), (state() -> {a, state()}), timeout :: integer()) :: a when a: var
  def get_and_update(agent, fun, timeout) when is_function(fun, 1) do
    Tangent.Test.Agent.get_and_update(agent, fun, timeout, self())
  end

  @spec get_and_update(agent(), module(), atom(), [term()], timeout :: integer()) :: any()
  def get_and_update(agent, module, fun, args, timeout) do
    Tangent.Test.Agent.get_and_update(agent, module, fun, args, timeout, self())
  end

  @spec update(agent(), (state() -> state()), timeout :: integer()) :: :ok
  def update(agent, fun, timeout) when is_function(fun, 1) do
    Tangent.Test.Agent.update(agent, fun, timeout, self())
  end

  @spec update(agent(), module(), atom(), [term()], timeout :: integer()) :: :ok
  def update(agent, module, fun, args, timeout) do
    Tangent.Test.Agent.update(agent, module, fun, args, timeout, self())
  end

  @spec cast(agent(), (state() -> state())) :: :ok
  def cast(agent, fun) when is_function(fun, 1) do
    Tangent.Test.Agent.cast(agent, fun, self())
  end

  @spec cast(agent(), module(), atom(), [term()]) :: :ok
  def cast(agent, module, fun, args) do
    Tangent.Test.Agent.cast(agent, module, fun, args, self())
  end

  @spec stop(agent(), reason :: term(), timeout :: integer()) :: :ok
  def stop(agent, reason, timeout) do
    GenServer.stop(agent, reason, timeout)
  end
end
