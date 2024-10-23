defmodule Admin.Medications.MedicalMedications do
  use Postgres.Service
  alias Admin.Medications.MedicalMedication

  # TODO: write tests
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

  @spec get_by_id(id :: pos_integer()) :: {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def get_by_id(id) when is_integer(id) do
    MedicalMedication
    |> Repo.fetch_by(id: id)
  end

  def get_by_id(_), do: {:error, :not_found}

  @spec get_by_name(name :: String.t()) :: {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def get_by_name(name) when is_binary(name) do
    MedicalMedication
    |> Repo.fetch_by(name: name)
  end

  def get_by_name(_name), do: {:error, :not_found}
end
