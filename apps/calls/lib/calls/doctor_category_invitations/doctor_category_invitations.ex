defmodule Calls.DoctorCategoryInvitations do
  use Postgres.Schema
  use Postgres.Service

  defmodule PendingInvitation do
    use Postgres.Schema

    @primary_key false
    schema "doctor_category_invitations" do
      field :call_id, :string, primary_key: true
      field :category_id, :integer, primary_key: true

      field :invited_by_specialist_id, :integer
      field :patient_id, :integer
      field :record_id, :integer
      field :session_id, :string
      field :team_id, :integer

      timestamps()
    end
  end

  @fields [
    :call_id,
    :category_id,
    :invited_by_specialist_id,
    :patient_id,
    :record_id,
    :session_id,
    :team_id
  ]
  defp create_invitation_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:_invitation,
      name: :doctor_category_invitations_pkey,
      message: "the category of doctors have been invited already"
    )
  end

  def fetch_invitations(specialist_id, category_id) do
    if team_id = Teams.specialist_team_id(specialist_id) do
      PendingInvitation
      |> where(category_id: ^category_id)
      |> where(team_id: ^team_id)
      |> order_by(asc: :inserted_at)
      |> Repo.fetch_all()
    else
      {:ok, []}
    end
  end

  def invite_category(params) do
    %PendingInvitation{}
    |> create_invitation_changeset(params)
    |> Repo.insert()
  end

  def delete_invitation(call_id, category_id) do
    with {:ok, invitation} <- fetch_invitation(call_id, category_id) do
      Repo.delete(invitation)
    end
  end

  defp fetch_invitation(call_id, category_id) do
    PendingInvitation
    |> where(call_id: ^call_id, category_id: ^category_id)
    |> Repo.fetch_one()
  end
end
