defmodule Postgres.Repo.Migrations.MovePhoneNumberFromSpecialistLocationToBasicProfile do
  use Ecto.Migration

  def change do
    alter table(:specialist_basic_infos) do
      add :phone_number, :string
    end

    execute """
    UPDATE specialist_basic_infos
    SET phone_number=specialist_locations.phone_number FROM specialist_locations
    WHERE specialist_basic_infos.specialist_id=specialist_locations.specialist_id
    """

    alter table(:specialist_locations) do
      remove :phone_number, :string
    end
  end
end
