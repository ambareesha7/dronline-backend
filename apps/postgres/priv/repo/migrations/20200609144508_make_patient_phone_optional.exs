defmodule Postgres.Repo.Migrations.MakePatientPhoneOptional do
  use Ecto.Migration

  def up do
    # Cleanup old rules

    alter table(:patient_invitations) do
      modify :phone_number, :string, null: true
      add :email, :string
    end

    execute """
    DROP INDEX IF EXISTS patient_invitations_phone_number_specialist_id_index
    """

    # Add new rules

    create constraint(
             :patient_invitations,
             "email_or_phone_number_required_constraint",
             check: "email is not null or phone_number is not null"
           )

    execute """
    CREATE UNIQUE INDEX IF NOT EXISTS patient_invitations_phone_number_unique_constraint
      ON patient_invitations (phone_number, specialist_id)
      WHERE phone_number IS NOT NULL
    """

    execute """
    CREATE UNIQUE INDEX IF NOT EXISTS patient_invitations_email_unique_constraint
      ON patient_invitations (email, specialist_id)
      WHERE email IS NOT NULL
    """
  end

  def down do
    alter table(:patient_invitations) do
      modify :phone_number, :string, null: false
      remove :email
    end

    execute """
    ALTER TABLE patient_invitations 
      DROP CONSTRAINT IF EXISTS email_or_phone_number_required_constraint
    """

    execute "DROP INDEX IF EXISTS patient_invitations_phone_number_unique_constraint"
    execute "DROP INDEX IF EXISTS patient_invitations_email_unique_constraint"
  end
end
