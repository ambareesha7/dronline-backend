defmodule EMR.PatientRecords.Timeline.ItemData.DoctorInvitation do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.Timeline.Commands.CreateDoctorInvitationItem
  alias EMR.PatientRecords.Timeline.ItemData.DoctorInvitation

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "doctor_invitations" do
    field :medical_category_id, :integer

    field :specialist_id, :integer
    field :timeline_id, :integer
    field :patient_id, :integer

    timestamps()
  end

  @fields [:medical_category_id, :patient_id, :specialist_id, :timeline_id]
  defp create_changeset(%DoctorInvitation{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  @spec create(%CreateDoctorInvitationItem{}) ::
          {:ok, %DoctorInvitation{}}
          | {:error, Ecto.Changeset.t()}
  def create(%CreateDoctorInvitationItem{} = cmd) do
    params = %{
      patient_id: cmd.patient_id,
      specialist_id: cmd.specialist_id,
      timeline_id: cmd.record_id,
      medical_category_id: cmd.medical_category_id
    }

    %DoctorInvitation{}
    |> create_changeset(params)
    |> Repo.insert()
  end

  @impl true
  def specialist_ids_in_item(%__MODULE__{} = struct) do
    [struct.specialist_id]
  end

  @impl true
  def display_name do
    "Invitation Sent"
  end
end
