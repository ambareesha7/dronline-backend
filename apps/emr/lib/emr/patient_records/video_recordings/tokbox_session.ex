defmodule EMR.PatientRecords.VideoRecordings.TokboxSession do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "record_tokbox_sessions" do
    field :tokbox_session_id, :string

    field :record_id, :integer

    timestamps()
  end

  @spec assign_tokbox_session_to_record(pos_integer, String.t()) :: :ok
  def assign_tokbox_session_to_record(record_id, tokbox_session_id) when record_id > 0 do
    {:ok, %__MODULE__{}} =
      %__MODULE__{record_id: record_id, tokbox_session_id: tokbox_session_id}
      |> Repo.insert()

    :ok
  end

  @spec get_record_id_for_tokbox_session(String.t()) :: pos_integer | nil
  def get_record_id_for_tokbox_session(tokbox_session_id) do
    __MODULE__
    |> where(tokbox_session_id: ^tokbox_session_id)
    |> select([ts], ts.record_id)
    |> Repo.one()
  end
end
