defmodule Tangent.Test do
  @moduledoc """
  Functions to use in tests to register agent state overloads.
  """

  defmacro __using__(_opts \\ []) do
    quote do
      import Tangent.Test
    end
  end

  @spec overload(module()) :: Macro.t()
  defmacro overload(agent_module) do
    if Mix.env() == :test do
      quote do
        Tangent.Test.Agent.register(unquote(agent_module), self())
      end
    else
      raise "Tangent overloads should only be used when Mix.env() == :test"
    end
  end
end
