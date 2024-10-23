defmodule EMR.Medications.MedicationOrdersTest do
  use Postgres.DataCase

  alias EMR.Medications.MedicationOrders

  describe "medication_orders" do
    alias EMR.Medications.MedicationOrder

    import EMR.Medications.MedicationOrdersFixtures

    @invalid_attrs %{delivery_address: nil, delivery_status: nil, payment_status: nil}

    test "list_medication_orders/0 returns all medication_orders" do
      medication_order = medication_order_fixture()
      assert MedicationOrders.list_medication_orders() == [medication_order]
    end

    test "get_medication_order!/1 returns the medication_order with given id" do
      medication_order = medication_order_fixture()
      assert MedicationOrders.get_medication_order!(medication_order.id) == medication_order
    end

    test "create_medication_order/1 with valid data creates a medication_order" do
      valid_attrs = %{
        delivery_address: "some delivery_address",
        delivery_status: :delivered,
        payment_status: :paid
      }

      assert {:ok, %MedicationOrder{} = medication_order} =
               MedicationOrders.create_medication_order(valid_attrs)

      assert medication_order.delivery_address == "some delivery_address"
      assert medication_order.delivery_status == :delivered
      assert medication_order.payment_status == :paid
    end

    test "create_medication_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               MedicationOrders.create_medication_order(@invalid_attrs)
    end

    test "update_medication_order/2 with valid data updates the medication_order" do
      medication_order = medication_order_fixture()

      update_attrs = %{
        delivery_address: "some updated delivery_address",
        delivery_status: :cancelled,
        payment_status: :cancelled
      }

      assert {:ok, %MedicationOrder{} = medication_order} =
               MedicationOrders.update_medication_order(medication_order, update_attrs)

      assert medication_order.delivery_address == "some updated delivery_address"
      assert medication_order.delivery_status == :cancelled
      assert medication_order.payment_status == :cancelled
    end

    test "update_medication_order/2 with invalid data returns error changeset" do
      medication_order = medication_order_fixture()

      assert {:error, %Ecto.Changeset{}} =
               MedicationOrders.update_medication_order(medication_order, @invalid_attrs)

      assert medication_order == MedicationOrders.get_medication_order!(medication_order.id)
    end

    test "delete_medication_order/1 deletes the medication_order" do
      medication_order = medication_order_fixture()

      assert {:ok, %MedicationOrder{}} =
               MedicationOrders.delete_medication_order(medication_order)

      assert_raise Ecto.NoResultsError, fn ->
        MedicationOrders.get_medication_order!(medication_order.id)
      end
    end

    test "change_medication_order/1 returns a medication_order changeset" do
      medication_order = medication_order_fixture()
      assert %Ecto.Changeset{} = MedicationOrders.change_medication_order(medication_order)
    end
  end
end

defmodule EMR.Medications.MedicationOrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EMR.Medications.MedicationOrders` context.
  """

  @doc """
  Generate a medication_order.
  """
  def medication_order_fixture(attrs \\ %{}) do
    {:ok, medication_order} =
      attrs
      |> Enum.into(%{
        delivery_address: "some delivery_address",
        delivery_status: :delivered,
        payment_status: :paid
      })
      |> EMR.Medications.MedicationOrders.create_medication_order()

    medication_order
  end
end
