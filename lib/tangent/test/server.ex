defmodule Tangent.Test.Server do
  @moduledoc false
  use GenServer

  defstruct [:global, :initial, monitors: %{}, per_process: %{}]

  @type t() :: %__MODULE__{
          global: term(),
          initial: term(),
          per_process: %{pid() => term()}
        }

  @spec init(initial: term()) :: {:ok, t()}
  def init(initial: fun) do
    initial = run(fun, [])
    {:ok, __struct__(initial: initial, global: initial)}
  end

  def handle_call({:get, fun, caller}, _from, state) do
    value = run(fun, [data(state, caller)])
    {:reply, value, state}
  end

  def handle_call({:get_and_update, fun, caller}, _from, state) do
    case run(fun, [data(state, caller)]) do
      {reply, new_data} -> {:reply, reply, update(state, new_data, caller)}
      other -> {:stop, {:bad_return_value, other}, state}
    end
  end

  def handle_call({:update, fun, caller}, _from, state) do
    new_data = run(fun, [data(state, caller)])
    {:reply, :ok, update(state, new_data, caller)}
  end

  def handle_cast({:cast, fun, caller}, state) do
    new_data = run(fun, [data(state, caller)])
    {:noreply, update(state, new_data, caller)}
  end

  defp data(state, caller) do
    if Map.keys(state.per_process) |> Enum.member?(caller),
      do: state.per_process[caller],
      else: state.global
  end

  defp run({m, f, a}, extra), do: apply(m, f, extra ++ a)
  defp run(fun, extra), do: apply(fun, extra)

  defp update(state, data, caller) do
    if Map.keys(state.per_process) |> Enum.member?(caller) do
      %{state | per_process: Map.put(state.per_process, caller, data)}
    else
      %{state | global: data}
    end
  end
end
