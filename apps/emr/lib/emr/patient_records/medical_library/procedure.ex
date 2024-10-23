defmodule EMR.PatientRecords.MedicalLibrary.Procedure do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :string, autogenerate: false}
  schema "medical_procedures" do
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
    |> where([p], fragment("(? || ?) ILIKE ('%' || ? || '%')", p.id, p.name, ^filter))
  end

  defp search(query, _filter), do: query
end
