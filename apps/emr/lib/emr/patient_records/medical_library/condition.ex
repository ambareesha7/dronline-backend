defmodule EMR.PatientRecords.MedicalLibrary.Condition do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :string, autogenerate: false}
  schema "medical_conditions" do
    field :name, :string
  end

  def fetch(filter) do
    __MODULE__
    |> search(filter)
    |> limit(200)
    |> Repo.all()
  end

  defp search(query, filter) when is_binary(filter) and byte_size(filter) > 0 do
    query
    |> where([c], fragment("(? || ?) ILIKE ('%' || ? || '%')", c.id, c.name, ^filter))
  end

  defp search(query, _filter), do: query
end
