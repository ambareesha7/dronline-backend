defmodule EMR.Medications.PaymentsTest do
  use Postgres.DataCase, async: true

  alias EMR.Medications.Payment
  alias EMR.Medications.Payments

  describe "create/1" do
    setup do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_specialist)

      %{id: bundle_id} =
        EMR.Factory.insert(:medications_bundle,
          patient_id: patient.id,
          specialist_id: specialist.id,
          medications: [%{name: "medication_1"}],
          timeline_id: 1
        )

      %{id: order_id} =
        EMR.Factory.insert(:medication_order,
          patient_id: patient.id,
          medications_bundle_id: bundle_id
        )

      {:ok, bundle_id: bundle_id, order_id: order_id}
    end

    test "creates payment", %{bundle_id: bundle_id, order_id: order_id} do
      assert {:ok,
              %Payment{
                medications_bundle_id: ^bundle_id,
                medication_order_id: ^order_id,
                transaction_reference: "abc123",
                payment_method: :TELR,
                price: %Money{amount: 10000, currency: :AED}
              }} =
               Payments.create(%{
                 medications_bundle_id: bundle_id,
                 medication_order_id: order_id,
                 transaction_reference: "abc123",
                 payment_method: "TELR",
                 amount: 10000,
                 currency: :AED
               })
    end

    # test "when creating multiple payments for one bundle_id, raises error", %{
    #   bundle_id: bundle_id
    # } do
    #   params = %{
    #     medications_bundle_id: bundle_id,
    #     transaction_reference: "abc123",
    #     payment_method: "TELR",
    #     amount: "10000",
    #     currency: "AED"
    #   }

    #   assert {:ok, %Payment{}} = Payments.create(params)

    #   assert_raise Ecto.ConstraintError, fn -> Payments.create(params) end
    # end

    test "doesn't create payment without required fields" do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  medications_bundle_id: {"can't be blank", [validation: :required]},
                  medication_order_id: {"can't be blank", [validation: :required]}
                ],
                valid?: false
              }} =
               Payments.create(%{
                 transaction_reference: "abc123",
                 payment_method: "TELR",
                 amount: 10000,
                 currency: :AED
               })
    end
  end
end
