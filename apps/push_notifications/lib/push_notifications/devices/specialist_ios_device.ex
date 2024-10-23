defmodule PushNotifications.Devices.SpecialistIOSDevice do
  use Postgres.Schema
  use Postgres.Service

  schema "specialist_ios_devices" do
    field :device_token, :string

    field :specialist_id, :integer

    timestamps()
  end

  @doc """
  Register new specialist device.

  If existing token is passed then specialist_id is updated.
  It means that someone logged out and logged in on the same device.
  """
  @spec register(pos_integer(), String.t()) :: {:ok, %__MODULE__{}}
  def register(specialist_id, device_token) do
    device = %__MODULE__{specialist_id: specialist_id, device_token: device_token}
    set_on_conflict = [specialist_id: specialist_id, updated_at: DateTime.utc_now()]

    Repo.insert(device, on_conflict: [set: set_on_conflict], conflict_target: :device_token)
  end

  @spec unregister(pos_integer, String.t()) :: :ok
  def unregister(specialist_id, device_token) do
    _ =
      __MODULE__
      |> where(specialist_id: ^specialist_id, device_token: ^device_token)
      |> Repo.delete_all()

    :ok
  end
end
