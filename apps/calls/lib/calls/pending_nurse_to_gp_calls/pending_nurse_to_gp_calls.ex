defmodule Calls.PendingNurseToGPCalls do
  use Postgres.Schema
  use Postgres.Service

  defmodule PendingCall do
    use Postgres.Schema

    @primary_key {:nurse_id, :id, autogenerate: false}
    schema "pending_nurse_to_gp_calls" do
      field :record_id, :integer
      field :patient_id, :integer

      timestamps()
    end
  end

  @fields [:nurse_id, :record_id, :patient_id]
  defp add_call_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:nurse_id,
      name: :pending_nurse_to_gp_calls_pkey,
      message: "the nurse is already in queue"
    )
    |> foreign_key_constraint(:nurse_id)
    |> foreign_key_constraint(:record_id)
    |> foreign_key_constraint(:patient_id)
  end

  @spec fetch() :: {:ok, [%PendingCall{}]}
  def fetch do
    PendingCall
    |> order_by(asc: :inserted_at)
    |> Repo.fetch_all()
  end

  @spec add_call(map) :: {:ok, %PendingCall{}} | {:error, Ecto.Changeset.t()}
  def add_call(params) do
    %PendingCall{}
    |> add_call_changeset(params)
    |> Repo.insert()
  end

  @spec remove_call(pos_integer) ::
          {:ok, %PendingCall{}} | {:error, :nurse_is_not_in_queue}
  def remove_call(nurse_id) do
    with {:ok, pending_call} <- fetch_by_nurse_id(nurse_id),
         {:ok, pending_call} <- Repo.delete(pending_call) do
      {:ok, pending_call}
    else
      _error ->
        {:error, :nurse_is_not_in_queue}
    end
  end

  defp fetch_by_nurse_id(nurse_id) do
    Repo.fetch_by(PendingCall, nurse_id: nurse_id)
  end
end
