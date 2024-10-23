defmodule Postgres.Repo.Migrations.AddGenderToSpecialistBasicInfo do
  use Ecto.Migration

  def change do
    alter table(:specialist_basic_infos) do
      add :gender, :string
    end

    execute "UPDATE specialist_basic_infos SET gender = 'MALE' WHERE TITLE = 'MR';"
    execute "UPDATE specialist_basic_infos SET gender = 'FEMALE' WHERE TITLE = 'MRS';"
    execute "UPDATE specialist_basic_infos SET gender = 'FEMALE' WHERE TITLE = 'MS';"
  end
end
