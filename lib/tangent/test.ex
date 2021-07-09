defmodule Tangent.Test do
  @moduledoc """
  Test helpers to register agent state overloads.

  ## Usage

      defmodule MyTest do
        use ExUnit.Case, async: true
        use Tangent.Test

        setup do
          Tangent.Test.overload(MyAgent)
        end

        # // ...
      end
  """

  defmacro __using__(_opts \\ []) do
    quote do
      import Tangent.Test
    end
  end

  @doc """
  Registers the current process as the owner of an overload. Processes that can trace
  their ancestry to the owner will access a segmented dataset when interacting with the
  named agent, rather than accessing global state.

  If passing an overload to a process that has not been started by the current process,
  `Tangent.Test.Agent.register/2` should be used directly.
  """
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
