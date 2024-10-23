defmodule Calls.CallSupervisor do
  use DynamicSupervisor

  def start_child(call_id) when is_binary(call_id) do
    DynamicSupervisor.start_child(__MODULE__, {Calls.Call, [call_id]})
  end

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
