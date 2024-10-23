defmodule Postgres.Repo.Migrations.MigratePatientLocationInDispatches do
  use Ecto.Migration
  import Ecto.Query

  def change do
    ["pending_dispatches", "ongoing_dispatches", "ended_dispatches"]
    |> Enum.each(&migrate_patient_locations/1)
  end

  # sobelow_skip ["Misc.BinToTerm"]
  defp migrate_patient_locations(dispatch_type) do
    dispatch_type
    |> select([:request_id, :encoded_patient_location])
    |> Postgres.Repo.all()
    |> Enum.each(fn %{request_id: request_id, encoded_patient_location: encoded_patient_location} ->
      {:address, old_address} =
        encoded_patient_location |> :erlang.binary_to_term() |> Map.get(:type)

      new_address = old_address |> Map.from_struct()

      dispatch_type
      |> where(request_id: ^request_id)
      |> Postgres.Repo.update_all(set: [patient_location_address: new_address])
    end)
  end
end
