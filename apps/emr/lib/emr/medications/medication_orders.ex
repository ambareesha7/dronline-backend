defmodule EMR.Medications.MedicationOrders do
  @moduledoc """
  The MedicationOrders context.
  """

  use Postgres.Service

  alias EMR.Medications.MedicationOrder

  @doc """
  Returns the list of medication_orders.

  ## Examples

      iex> list_medication_orders()
      [%MedicationOrder{}, ...]

  """
  def list_medication_orders do
    Repo.all(MedicationOrder)
  end

  @doc """
  Gets a single medication_order.

  ## Examples

      iex> get_medication_order(uuid)
      %MedicationOrder{}

      iex> get_medication_order(uuid)
      nil

  """
  def get_medication_order(id) do
    case Ecto.UUID.dump(id) do
      {:ok, _} ->
        Repo.get(MedicationOrder, id)

      _ ->
        nil
    end
  end

  @doc """
  Creates a medication_order.

  ## Examples

      iex> create_medication_order(%{field: value})
      {:ok, %MedicationOrder{}}

      iex> create_medication_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_medication_order(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create_medication_order(attrs \\ %{}) do
    %MedicationOrder{}
    |> MedicationOrder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a medication_order.

  ## Examples

      iex> update_medication_order(medication_order, %{field: new_value})
      {:ok, %MedicationOrder{}}

      iex> update_medication_order(medication_order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_medication_order(%MedicationOrder{} = medication_order, attrs) do
    medication_order
    |> MedicationOrder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a medication_order.

  ## Examples

      iex> delete_medication_order(medication_order)
      {:ok, %MedicationOrder{}}

      iex> delete_medication_order(medication_order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_medication_order(%MedicationOrder{} = medication_order) do
    Repo.delete(medication_order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking medication_order changes.

  ## Examples

      iex> change_medication_order(medication_order)
      %Ecto.Changeset{data: %MedicationOrder{}}

  """
  def change_medication_order(%MedicationOrder{} = medication_order, attrs \\ %{}) do
    MedicationOrder.changeset(medication_order, attrs)
  end
end
