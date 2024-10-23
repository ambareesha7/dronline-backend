defmodule PushNotifications.Devices.PatientIOSDevice do
  use Postgres.Schema
  use Postgres.Service

  schema "patient_ios_devices" do
    field :device_token, :string

    field :patient_id, :integer

    timestamps()
  end

  @doc """
  Register new patient IOS device.

  If existing token is passed then patient_id is updated.
  It means that someone logged out and logged in on the same device.
  """
  @spec register(pos_integer(), String.t()) :: {:ok, %__MODULE__{}}
  def register(patient_id, device_token) do
    device = %__MODULE__{patient_id: patient_id, device_token: device_token}
    set_on_conflict = [patient_id: patient_id, updated_at: DateTime.utc_now()]

    Repo.insert(device, on_conflict: [set: set_on_conflict], conflict_target: :device_token)
  end

  @spec unregister(pos_integer, String.t()) :: :ok
  def unregister(patient_id, device_token) do
    _ =
      __MODULE__
      |> where(patient_id: ^patient_id, device_token: ^device_token)
      |> Repo.delete_all()

    :ok
  end

  @spec all_tokens_for_patient_id(pos_integer) :: [String.t()]
  def all_tokens_for_patient_id(patient_id) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> select([d], d.device_token)
    |> Postgres.Repo.all()
  end
end
