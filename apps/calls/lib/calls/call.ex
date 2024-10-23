defmodule Calls.Call do
  use GenServer, restart: :temporary

  defmodule State do
    defstruct [
      :call_id,
      :patient_location_coordinates,
      client_pids: [],
      specialist_categories_invited: []
    ]
  end

  @doc false
  def start_link([call_id]) do
    GenServer.start_link(__MODULE__, [call_id], name: {:global, name(call_id)})
  end

  @spec start() :: String.t()
  def start do
    call_id = UUID.uuid4()
    {:ok, _pid} = Calls.CallSupervisor.start_child(call_id)
    call_id
  end

  @spec in_progress?(String.t()) :: boolean()
  def in_progress?(call_id) do
    case :global.whereis_name(name(call_id)) do
      pid when is_pid(pid) -> alive?(pid)
      _ -> false
    end
  end

  defp alive?(pid) do
    node = :erlang.node(pid)
    :rpc.call(node, Process, :alive?, [pid])
  end

  @spec join(String.t(), pid()) :: :ok | {:error, :invalid_call_id}
  def join(call_id, client_pid) do
    call(call_id, {:join, client_pid})
  end

  def invite_specialist(call_id, medical_category_id) do
    call(call_id, {:invite_specialist, medical_category_id})
  end

  def store_patient_location_coordinates(call_id, %{lat: _, lon: _} = coordinates) do
    call(call_id, {:store_patient_location_coordinates, coordinates})
  end

  def get_patient_location_coordinates(call_id) do
    call(call_id, :get_patient_location_coordinates)
  end

  def init([call_id]) do
    state = %State{
      call_id: call_id,
      client_pids: [],
      specialist_categories_invited: []
    }

    timeout = :timer.minutes(5)
    {:ok, state, timeout}
  end

  def handle_call({:join, client_pid}, _from, state) do
    new_pids = Enum.uniq([client_pid | state.client_pids])
    Process.monitor(client_pid)
    {:reply, :ok, %{state | client_pids: new_pids}}
  end

  def handle_call({:invite_specialist, medical_category_id}, _from, state) do
    new_category_ids = Enum.uniq([medical_category_id | state.specialist_categories_invited])
    {:reply, :ok, %{state | specialist_categories_invited: new_category_ids}}
  end

  def handle_call({:store_patient_location_coordinates, coordinates}, _from, state) do
    new_state = %{state | patient_location_coordinates: coordinates}
    {:reply, :ok, new_state}
  end

  def handle_call(:get_patient_location_coordinates, _from, state) do
    {:reply, state.patient_location_coordinates, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    new_pids = Enum.reject(state.client_pids, &(&1 == pid))
    new_state = %{state | client_pids: new_pids}

    case new_pids do
      [] -> stop(new_state)
      [_ | _] -> {:noreply, new_state}
    end
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  defp stop(state) do
    for category_id <- state.specialist_categories_invited do
      cmd = %Calls.DoctorCategoryInvitations.Commands.CancelInvitation{
        call_id: state.call_id,
        category_id: category_id
      }

      Calls.DoctorCategoryInvitations.Commands.cancel_invitation(cmd)
    end

    {:stop, :normal, state}
  end

  defp call(call_id, message) do
    case :global.whereis_name(name(call_id)) do
      pid when is_pid(pid) -> GenServer.call(pid, message)
      _ -> {:error, :invalid_call_id}
    end
  end

  defp name(call_id) do
    "call:#{call_id}"
  end
end
