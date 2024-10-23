defmodule Postgres.Seeder do
  @moduledoc """
  Inserts pre-defined data into database:
  - seed library tables
  - seed dev users
  Safe to run repeatedly (existing items are ignored or updated).
  """
  require Logger

  alias Postgres.Seeds.Countries
  alias Postgres.Seeds.InsuranceProviders
  alias Postgres.Seeds.MedicalCategories
  alias Postgres.Seeds.MedicalConditions
  alias Postgres.Seeds.MedicalMedications
  alias Postgres.Seeds.MedicalProcedures
  alias Postgres.Seeds.MedicalTests
  alias Postgres.Seeds.MedicalTestsCategories
  alias Postgres.Seeds.Specialists

  def seed_staging(shared_password, admin_password, email_prefix \\ "dronline+stg") do
    _ = seed(shared_password, admin_password, email_prefix)
  end

  def seed_prod(shared_password, admin_password, email_prefix \\ "dronline+") do
    _ = seed(shared_password, admin_password, email_prefix)
  end

  defp seed(shared_password, admin_password, email_prefix) do
    with _ <- Postgres.migrate!(),
         :ok <- seed_library_tables(),
         :ok <- Specialists.seed(shared_password, admin_password, email_prefix) do
      _ = Logger.info("--- Seeding completed ✓ ---")
    else
      other ->
        _ = Logger.error(other)
        throw("Seeder error")
    end
  end

  defp seed_library_tables do
    _ = MedicalCategories.seed()
    _ = MedicalConditions.seed()
    _ = MedicalMedications.seed()
    _ = MedicalProcedures.seed()
    _ = MedicalTestsCategories.seed()
    _ = MedicalTests.seed()
    _ = Countries.seed()
    _ = InsuranceProviders.seed()

    :ok
  end
end
