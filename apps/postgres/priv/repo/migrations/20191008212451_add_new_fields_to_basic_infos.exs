defmodule Postgres.Repo.Migrations.AddNewFieldsToBasicInfos do
  use Ecto.Migration

  def change do
    alter table(:patient_basic_infos) do
      add :gender, :string
    end

    execute "UPDATE patient_basic_infos SET gender = 'MALE' WHERE TITLE = 'MR';"
    execute "UPDATE patient_basic_infos SET gender = 'FEMALE' WHERE TITLE = 'MRS';"
    execute "UPDATE patient_basic_infos SET gender = 'FEMALE' WHERE TITLE = 'MS';"
  end
end
