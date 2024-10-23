defmodule EMR.PatientRecords.Timeline.Item do
  use Postgres.Schema
  use Postgres.Service

  import Mockery.Macro

  alias EMR.PatientRecords.InvolvedSpecialists

  alias EMR.PatientRecords.Timeline.Item
  alias EMR.PatientRecords.Timeline.ItemData

  alias EMR.PatientRecords.Timeline.Commands.CreateCallItem
  alias EMR.PatientRecords.Timeline.Commands.CreateCallRecordingItem
  alias EMR.PatientRecords.Timeline.Commands.CreateDispatchRequestItem
  alias EMR.PatientRecords.Timeline.Commands.CreateDoctorInvitationItem

  @item_types [
    :call,
    :call_recording,
    :dispatch_request,
    :doctor_invitation,
    :hpi,
    :vitals,
    :vitals_v2,
    :ordered_tests_bundle,
    :medications_bundle
  ]

  @auto_join_and_preload_types @item_types -- [:ordered_tests_bundle]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "timeline_items" do
    field :comments_counter, :integer, default: 0

    belongs_to :call, ItemData.Call
    belongs_to :call_recording, ItemData.CallRecording
    belongs_to :dispatch_request, ItemData.DispatchRequest
    belongs_to :doctor_invitation, ItemData.DoctorInvitation
    belongs_to :hpi, EMR.HPI
    belongs_to :vitals, ItemData.Vitals
    belongs_to :vitals_v2, EMR.PatientRecords.Vitals, type: :binary_id
    belongs_to :ordered_tests_bundle, EMR.PatientRecords.OrderedTestsBundle
    belongs_to :medications_bundle, EMR.PatientRecords.MedicationsBundle

    field :patient_id, :integer
    field :timeline_id, :integer

    timestamps()
  end

  @item_data_foreign_keys for item_type <- @item_types, do: :"#{item_type}_id"
  @fields [:patient_id, :timeline_id] ++ @item_data_foreign_keys
  defp create_changeset(%__MODULE__{} = item, params) do
    item
    |> cast(params, @fields)
    |> validate_required([:patient_id, :timeline_id])
  end

  @spec get(String.t()) :: %__MODULE__{} | nil
  def get(id) do
    Repo.get(__MODULE__, id)
  end

  @doc """
  It adds `join`s and `preload`s for every type of timeline item to given query
  """
  @spec join_and_preload_all_item_types(Ecto.Query.t()) :: Ecto.Query.t()
  def join_and_preload_all_item_types(query) do
    Enum.reduce(@item_types, query, fn item_type, query ->
      query |> join_and_preload(item_type)
    end)
  end

  @doc """
  Returns list of specialist ids related to timeline item.

  Item must have preloaded all item data assocs
  """
  @spec specialist_ids_in_item(%Item{}) :: [pos_integer]
  def specialist_ids_in_item(timeline_item) do
    Enum.reduce_while(@item_types, [], fn item_type, _acc ->
      case Map.get(timeline_item, item_type) do
        %struct{} = data -> {:halt, struct.specialist_ids_in_item(data)}
        nil -> {:cont, []}
      end
    end)
  end

  @spec create_call_item(%CreateCallItem{}) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_call_item(%CreateCallItem{} = cmd) do
    with {:ok, call} <- ItemData.Call.create(cmd) do
      params = %{patient_id: cmd.patient_id, timeline_id: cmd.record_id, call_id: call.id}

      create_item(params)
    end
  end

  @spec create_call_recording_item(%CreateCallRecordingItem{}) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_call_recording_item(%CreateCallRecordingItem{} = cmd) do
    with {:ok, call_recording} <- ItemData.CallRecording.create(cmd) do
      params = %{
        patient_id: cmd.patient_id,
        timeline_id: cmd.record_id,
        call_recording_id: call_recording.id
      }

      create_item(params)
    end
  end

  @spec create_doctor_invitation_item(%CreateDoctorInvitationItem{}) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_doctor_invitation_item(%CreateDoctorInvitationItem{} = cmd) do
    with {:ok, doctor_invitation} <- ItemData.DoctorInvitation.create(cmd) do
      params = %{
        patient_id: cmd.patient_id,
        timeline_id: cmd.record_id,
        doctor_invitation_id: doctor_invitation.id
      }

      create_item(params)
    end
  end

  @spec create_ordered_tests_bundle_item(non_neg_integer, non_neg_integer, String.t()) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_ordered_tests_bundle_item(patient_id, record_id, ordered_tests_bundle_id) do
    params = %{
      patient_id: patient_id,
      timeline_id: record_id,
      ordered_tests_bundle_id: ordered_tests_bundle_id
    }

    create_item(params)
  end

  @spec create_medications_bundle_item(non_neg_integer, non_neg_integer, String.t()) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_medications_bundle_item(patient_id, record_id, medications_bundle_id) do
    params = %{
      patient_id: patient_id,
      timeline_id: record_id,
      medications_bundle_id: medications_bundle_id
    }

    create_item(params)
  end

  @spec create_vitals_v2_item(non_neg_integer, non_neg_integer, String.t()) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_vitals_v2_item(patient_id, record_id, vitals_id) do
    params = %{patient_id: patient_id, timeline_id: record_id, vitals_v2_id: vitals_id}

    create_item(params)
  end

  @spec create_dispatch_request_item(%CreateDispatchRequestItem{}) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_dispatch_request_item(%CreateDispatchRequestItem{} = cmd) do
    with {:ok, dispatch_request} <- ItemData.DispatchRequest.create(cmd) do
      params = %{
        patient_id: cmd.patient_id,
        timeline_id: cmd.record_id,
        dispatch_request_id: dispatch_request.id
      }

      create_item(params)
    end
  end

  @spec create_hpi_item(non_neg_integer, non_neg_integer, non_neg_integer) ::
          {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create_hpi_item(patient_id, record_id, hpi_id) do
    params = %{patient_id: patient_id, timeline_id: record_id, hpi_id: hpi_id}

    create_item(params)
  end

  defp create_item(params) do
    %Item{}
    |> create_changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, %Item{id: id}} ->
        item =
          id
          |> get_preloaded_item_by_id()
          |> broadcast_new_timeline_item()
          |> register_specialists_involevement()

        {:ok, item}

      error ->
        error
    end
  end

  @spec get_preloaded_item_by_id(String.t()) :: %Item{}
  defp get_preloaded_item_by_id(id) do
    %Item{} =
      Item
      |> where(id: ^id)
      |> join_and_preload_all_item_types()
      |> Repo.one()
  end

  defp join_and_preload(query, :ordered_tests_bundle) do
    query
    |> join(:left, [t], _otb in assoc(t, :ordered_tests_bundle), as: :ordered_tests_bundle)
    |> join(:left, [ordered_tests_bundle: otb], _ot in assoc(otb, :ordered_tests),
      as: :ordered_tests
    )
    |> join(:left, [ordered_tests: ot], _mt in assoc(ot, :medical_test), as: :medical_tests)
    |> preload(
      [
        ordered_tests_bundle: otb,
        ordered_tests: ot,
        medical_tests: mt
      ],
      ordered_tests_bundle: {otb, ordered_tests: {ot, medical_test: mt}}
    )
  end

  # `:as` must be a compile-time atom therefore unquote was necessary
  for item_type <- @auto_join_and_preload_types do
    defp join_and_preload(query, unquote(item_type) = item_type) do
      query
      |> join(:left, [t], _j in assoc(t, ^item_type), as: unquote(item_type))
      |> preload([{^item_type, p}], [{^item_type, p}])
    end
  end

  defmacrop channel_broadcast do
    quote do: mockable(ChannelBroadcast, by: ChannelBroadcastMock)
  end

  defp broadcast_new_timeline_item(timeline_item) do
    channel_broadcast().broadcast({:new_timeline_item, timeline_item})

    timeline_item
  end

  defp register_specialists_involevement(timeline_item) do
    timeline_item
    |> specialist_ids_in_item()
    |> Enum.each(fn specialist_id ->
      patient_id = timeline_item.patient_id
      record_id = timeline_item.timeline_id

      :ok = InvolvedSpecialists.register_involvement(patient_id, record_id, specialist_id)
    end)

    timeline_item
  end

  @doc false
  def item_types, do: @item_types
end
