defmodule EMR.PatientRecords.MedicalLibrary.Medication do
  use Postgres.Schema
  use Postgres.Service

  schema "medical_medications" do
    field :name, :string
    field :price_aed, :integer
  end

  def fetch(filter) do
    __MODULE__
    |> search(filter)
    |> limit(200)
    |> Repo.all()
  end

  defp search(query, filter) when is_binary(filter) and byte_size(filter) > 0 do
    query
    |> where([m], fragment("? ILIKE ('%' || ? || '%')", m.name, ^filter))
  end

  defp search(query, _filter), do: query
end
