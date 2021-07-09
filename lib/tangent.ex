defmodule Tangent do
  @moduledoc """
  Documentation for `Tangent`.
  """

  @type on_start() :: Agent.on_start()
  @type agent() :: Agent.agent()
  @type state() :: term()

  defmacro __using__(opts) do
    quote do
      require Tangent

      def child_spec(arg) do
        default = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [arg]}
        }

        Supervisor.child_spec(default, unquote(Macro.escape(opts)))
      end

      defoverridable(child_spec: 1)
    end
  end

  defmacro start_link(fun, options \\ []) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.start_link(__MODULE__, unquote(fun), unquote(options))
      end
    else
      quote do
        Tangent.Agent.Passthrough.start_link(unquote(fun), unquote(options))
      end
    end
  end

  defmacro start_link(module, fun, args, options \\ []) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.start_link(unquote(module), unquote(fun), unquote(args), unquote(options))
      end
    else
      quote do
        Tangent.Agent.Passthrough.start_link(unquote(module), unquote(fun), unquote(args), unquote(options))
      end
    end
  end

  defmacro get(agent, getter, timeout \\ 5000) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.get(unquote(agent), unquote(getter), unquote(timeout))
      end
    else
      quote do
        Tangent.Agent.Passthrough.get(unquote(agent), unquote(getter), unquote(timeout))
      end
    end
  end

  defmacro get(agent, module, fun, args, timeout \\ 5000) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.get(unquote(agent), unquote(module), unquote(fun), unquote(args), unquote(timeout))
      end
    else
      quote do
        Tangent.Agent.Passthrough.get(unquote(agent), unquote(module), unquote(fun), unquote(args), unquote(timeout))
      end
    end
  end

  defmacro get_and_update(agent, fun, timeout \\ 5000) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.get_and_update(unquote(agent), unquote(fun), unquote(timeout))
      end
    else
      quote do
        Tangent.Agent.Passthrough.get_and_update(unquote(agent), unquote(fun), unquote(timeout))
      end
    end
  end

  defmacro get_and_update(agent, module, fun, args, timeout \\ 5000) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.get_and_update(unquote(agent), unquote(module), unquote(fun), unquote(args), unquote(timeout))
      end
    else
      quote do
        Tangent.Agent.Passthrough.get_and_update(unquote(agent), unquote(module), unquote(fun), unquote(args), unquote(timeout))
      end
    end
  end

  defmacro update(agent, fun, timeout \\ 5000) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.update(unquote(agent), unquote(fun), unquote(timeout))
      end
    else
      quote do
        Tangent.Agent.Passthrough.update(unquote(agent), unquote(fun), unquote(timeout))
      end
    end
  end

  defmacro update(agent, module, fun, args, timeout \\ 5000) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.update(unquote(agent), unquote(module), unquote(fun), unquote(args), unquote(timeout))
      end
    else
      quote do
        Tangent.Agent.Passthrough.update(unquote(agent), unquote(module), unquote(fun), unquote(args), unquote(timeout))
      end
    end
  end

  defmacro cast(agent, fun) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.cast(unquote(agent), unquote(fun))
      end
    else
      quote do
        Tangent.Agent.Passthrough.cast(unquote(agent), unquote(fun))
      end
    end
  end

  defmacro cast(agent, module, fun, args) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.cast(unquote(agent), unquote(module), unquote(fun), unquote(args))
      end
    else
      quote do
        Tangent.Agent.Passthrough.cast(unquote(agent), unquote(module), unquote(fun), unquote(args))
      end
    end
  end

  defmacro stop(agent, reason \\ :normal, timeout \\ :infinity) do
    if Mix.env() == :test do
      quote do
        Tangent.Agent.Intercept.stop(unquote(agent), unquote(reason), unquote(timeout))
      end
    else
      quote do
        Tangent.Agent.Passthrough.stop(unquote(agent), unquote(reason), unquote(timeout))
      end
    end
  end
end
