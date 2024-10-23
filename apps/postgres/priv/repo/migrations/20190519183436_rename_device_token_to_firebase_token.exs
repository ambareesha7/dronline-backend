defmodule Postgres.Repo.Migrations.RenameDeviceTokenToFirebaseToken do
  use Ecto.Migration

  def change do
    rename table(:patient_devices), :token, to: :firebase_token

    rename table(:specialist_devices), :token, to: :firebase_token
  end
end
