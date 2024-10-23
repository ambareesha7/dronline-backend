defmodule Triage.PatientWaitingForDispatch do
  use Postgres.Schema

  @primary_key {:request_id, :string, autogenerate: false}

  schema "patients_waiting_for_dispatch" do
    field :patient_id, :integer

    timestamps()
  end

  @fields [:patient_id, :request_id]

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:patient_id)
    |> unique_constraint(:_patient_id,
      name: :patients_waiting_for_dispatch_patient_id_index,
      message: "another dispatch to this patient is already requested"
    )
  end
end
