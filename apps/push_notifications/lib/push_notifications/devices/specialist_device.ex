defmodule PushNotifications.Devices.SpecialistDevice do
  use Postgres.Schema
  use Postgres.Service

  schema "specialist_devices" do
    field :firebase_token, :string

    field :specialist_id, :integer

    timestamps()
  end

  @doc """
  Register new specialist device.

  If existing token is passed then specialist_id is updated.
  It means that someone logged out and logged in on the same device.
  """
  @spec register(pos_integer(), String.t()) :: {:ok, %__MODULE__{}}
  def register(specialist_id, firebase_token) do
    device = %__MODULE__{specialist_id: specialist_id, firebase_token: firebase_token}
    set_on_conflict = [specialist_id: specialist_id, updated_at: DateTime.utc_now()]

    Repo.insert(device, on_conflict: [set: set_on_conflict], conflict_target: :firebase_token)
  end

  @spec unregister(pos_integer, String.t()) :: :ok
  def unregister(specialist_id, firebase_token) do
    _ =
      __MODULE__
      |> where(specialist_id: ^specialist_id, firebase_token: ^firebase_token)
      |> Repo.delete_all()

    :ok
  end

  @spec unregister(String.t()) :: :ok
  def unregister(firebase_token) do
    _ =
      __MODULE__
      |> where(firebase_token: ^firebase_token)
      |> Repo.delete_all()

    :ok
  end

  @spec all_tokens_for_specialist_id(pos_integer) :: [String.t()]
  def all_tokens_for_specialist_id(specialist_id) when not is_list(specialist_id) do
    __MODULE__
    |> where(specialist_id: ^specialist_id)
    |> select([sd], sd.firebase_token)
    |> Postgres.Repo.all()
  end

  @spec all_tokens_for_specialist_ids([pos_integer]) :: [String.t()]
  def all_tokens_for_specialist_ids(specialist_ids) when is_list(specialist_ids) do
    __MODULE__
    |> where([sd], sd.specialist_id in ^specialist_ids)
    |> select([sd], sd.firebase_token)
    |> Postgres.Repo.all()
  end
end
