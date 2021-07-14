defmodule Tangent.Test.Server do
  @moduledoc false
  use GenServer

  defstruct [:global, :initial, monitors: %{}, per_process: %{}]

  @type t() :: %__MODULE__{
          global: term(),
          initial: term(),
          per_process: %{pid() => term()}
        }

  @type fun() :: function() | {module(), atom(), [any()]}

  @spec init(initial: fun()) :: {:ok, t()}
  def init(initial: fun) do
    initial = run(fun, [])
    {:ok, __struct__(initial: initial, global: initial)}
  end

  def handle_call({:register, owner}, _from, state) do
    Process.monitor(owner)

    if Map.has_key?(state.per_process, owner) do
      {:reply, :ok, state}
    else
      per_process = put_in(state.per_process, [owner], state.initial)
      {:reply, :ok, %{state | per_process: per_process}}
    end
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

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    per_process = Map.delete(state.per_process, pid)
    {:noreply, %{state | per_process: per_process}}
  end

  defp data(state, caller) do
    case overloaded_process(caller) do
      nil ->
        state.global

      pid ->
        state.per_process[pid]
    end
  end

  defp run({m, f, a}, extra), do: apply(m, f, extra ++ a)
  defp run(fun, extra), do: apply(fun, extra)

  defp update(state, data, caller) do
    case overloaded_process(caller) do
      nil ->
        %{state | global: data}

      pid ->
        %{state | per_process: Map.put(state.per_process, pid, data)}
    end
  end

  defp overloaded_process(caller) when is_pid(caller) do
    case overloaded?(caller) do
      pid when is_pid(pid) ->
        pid

      _ ->
        with {:dictionary, dictionary} <- Process.info(caller, :dictionary),
             [parent | _] <- Keyword.get(dictionary, :"$ancestors", :error) do
          overloaded_process(parent)
        else
          _ -> nil
        end
    end
  end

  defp overloaded_process(_other), do: nil

  defp overloaded?(pid) when is_pid(pid) do
    case Process.info(pid, :dictionary) do
      {:dictionary, dictionary} ->
        case dictionary |> Keyword.get(:__tangent_overload__) do
          pid when is_pid(pid) -> pid
          _ -> false
        end

      _ ->
        false
    end
  end
end
