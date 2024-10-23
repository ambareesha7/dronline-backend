defmodule Admin.Medications do
  @moduledoc """
  The Medications context.
  """

  import Ecto.Query, warn: false
  use Postgres.Schema
  alias Admin.Medications.NewMedication

  def fetch(filter) do
    NewMedication
    |> search(filter)
    |> limit(200)
    |> Repo.all()
  end

  defp search(query, filter) when is_binary(filter) and byte_size(filter) > 0 do
    query
    |> where([m], fragment("? ILIKE ('%' || ? || '%')", m.name, ^filter))
  end

  defp search(query, _filter), do: query

  def delete_all_medication do
    Repo.delete_all(NewMedication)
  end

  def seed_from_csv(path) do
    list =
      path
      |> File.stream!()
      |> CSV.decode!(headers: true, field_transform: &String.trim/1)
      |> Enum.to_list()
      # comment below line if there is no price is provided csv file
      |> Enum.map(fn f -> string_keys_to_atom_keys(f) end)

    NewMedication
    |> Repo.insert_all(
      list,
      log: false,
      on_conflict: {:replace, [:id]},
      conflict_target: :id
    )
  end

  def seed_old_table(path) do
    list =
      path
      |> File.stream!()
      |> CSV.decode!(headers: true, field_transform: &String.trim/1)
      |> Enum.to_list()
      |> Enum.map(fn f -> Map.put(f, "price_aed", round(parse_price(f["price_aed"]))) end)

    "medical_medications"
    |> Postgres.Repo.insert_all(
      list,
      log: false,
      on_conflict: :nothing,
      conflict_target: :name
    )
  end

  def delete_all_medication_old_table do
    Repo.delete_all("medical_medications")
  end

  def string_keys_to_atom_keys(map) when is_map(map) do
    _price = :price
    _currency = :currency

    map
    |> Map.put("price", parse_price(map["price"]))
    |> Map.put_new("currency", "AED")
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      atom_key = String.to_existing_atom(key)

      Map.put(acc, atom_key, value)
    end)
  end

  defp parse_price(field) when field in [nil, ""], do: 0.0

  defp parse_price(field) when is_integer(field) do
    field
    |> Integer.to_string()
    |> parse_price()
  end

  defp parse_price(field) when is_float(field), do: field

  defp parse_price(field) do
    case Float.parse(field) do
      :error ->
        0.0

      {result, _} ->
        result
    end
  end

  @doc """
  Returns the list of medications.

  ## Examples

      iex> list_medications()
      [%NewMedication{}, ...]

  """
  def list_medications do
    Repo.all(NewMedication)
  end

  def list_old_medications do
    query =
      from p in "medical_medications",
        select: %{id: p.id, name: p.name, price_aed: p.price_aed}

    Repo.all(query)
  end

  @doc """
  Gets a single medication.

  Raises `Ecto.NoResultsError` if the New medication does not exist.

  ## Examples

      iex> get_medication(123)
      %NewMedication{}

      iex> get_medication(456)
      nil

  """

  def get_medication(id) do
    case Ecto.UUID.dump(id) do
      {:ok, _} ->
        Repo.get(NewMedication, id)

      _ ->
        nil
    end
  end

  @doc """
  Creates a medication.

  ## Examples

      iex> create_medication(%{field: value})
      {:ok, %NewMedication{}}

      iex> create_medication(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_medication(attrs \\ %{}) do
    %NewMedication{}
    |> NewMedication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a medication.

  ## Examples

      iex> update_medication(new_medication, %{field: new_value})
      {:ok, %NewMedication{}}

      iex> update_medication(new_medication, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_medication(%NewMedication{} = new_medication, attrs) do
    new_medication
    |> NewMedication.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a medication.

  ## Examples

      iex> delete_medication(new_medication)
      {:ok, %NewMedication{}}

      iex> delete_medication(new_medication)
      {:error, %Ecto.Changeset{}}

  """
  def delete_medication(%NewMedication{} = new_medication) do
    Repo.delete(new_medication)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking new_medication changes.

  ## Examples

      iex> change_medication(new_medication)
      %Ecto.Changeset{data: %NewMedication{}}

  """
  def change_medication(%NewMedication{} = new_medication, attrs \\ %{}) do
    NewMedication.changeset(new_medication, attrs)
  end
end
