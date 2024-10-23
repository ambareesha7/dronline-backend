defmodule Postgres.Repo.Migrations.LoosenPatientInvitationsConstraints do
  use Ecto.Migration

  def up do
    execute """
    DROP INDEX IF EXISTS patient_invitations_email_unique_constraint;
    """

    execute """
    DROP INDEX IF EXISTS patient_invitations_phone_number_unique_constraint;
    """

    create unique_index(
             :patient_invitations,
             [:phone_number, :specialist_id],
             where: "email IS NULL"
           )

    create unique_index(
             :patient_invitations,
             [:email, :specialist_id],
             where: "phone_number IS NULL"
           )

    create unique_index(
             :patient_invitations,
             [:phone_number, :email, :specialist_id],
             where: "phone_number IS NOT NULL AND email IS NOT NULL"
           )
  end

  def down do
    drop index(
           :patient_invitations,
           [:phone_number, :specialist_id]
         )

    drop index(
           :patient_invitations,
           [:email, :specialist_id]
         )

    drop index(
           :patient_invitations,
           [:phone_number, :email, :specialist_id]
         )
  end
end
