defmodule Web.Api.EMR.MedicationsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetMedicationResponse
  alias Proto.EMR.GetMedicationsHistoryResponse
  # alias Proto.EMR.SaveMedicationPayments

  describe "GET history_for_record" do
    setup [:authenticate_patient]

    @tag medications_controller_history: true
    # mix test --only medications_controller_history:true

    test "returns correct list", %{
      conn: conn,
      current_patient: current_patient
    } do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      %{id: bundle_id} =
        EMR.Factory.insert(:medications_bundle,
          patient_id: current_patient.id,
          timeline_id: record.id,
          specialist_id: specialist.id,
          medications: [
            %{
              name: "medication 1",
              direction: "dir 1",
              quantity: "1",
              refills: 1,
              price_aed: 2000
            }
          ]
        )

      %EMR.Medications.Payment{} =
        EMR.Factory.insert(:medications_bundle_payment,
          medications_bundle_id: bundle_id,
          transaction_reference: "transaction_reference",
          payment_method: :TELR,
          price: %Money{amount: 299, currency: :AED}
        )

      path = emr_medications_path(conn, :history_for_record, record.id)
      conn = get(conn, path)

      assert %GetMedicationsHistoryResponse{
               bundles: [
                 %Proto.EMR.MedicationsBundle{
                   inserted_at: _inserted_at,
                   specialist_id: specialist_id,
                   medications: [
                     %Proto.EMR.MedicationsItem{
                       name: "medication 1",
                       direction: "dir 1",
                       quantity: "1",
                       refills: 1,
                       price_aed: 2000
                     }
                   ],
                   payments_params: %Proto.Generics.PaymentsParams{
                     amount: "299",
                     currency: "AED",
                     transaction_reference: "transaction_reference",
                     payment_method: :TELR
                   }
                 }
               ]
             } = proto_response(conn, 200, GetMedicationsHistoryResponse)

      assert specialist_id == specialist.id
    end
  end

  describe "GET show" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      %{id: bundle_id} =
        EMR.Factory.insert(:medications_bundle,
          patient_id: current_patient.id,
          timeline_id: record.id,
          specialist_id: specialist.id,
          medications: [
            %{
              name: "medication 1",
              direction: "dir 1",
              quantity: "1",
              refills: 1,
              price_aed: 2000
            }
          ]
        )

      %EMR.Medications.Payment{} =
        EMR.Factory.insert(:medications_bundle_payment,
          medications_bundle_id: bundle_id,
          transaction_reference: "transaction_reference",
          payment_method: :TELR,
          price: %Money{amount: 299, currency: :AED}
        )

      conn = get(conn, emr_medications_path(conn, :show, record.id, bundle_id))

      assert %GetMedicationResponse{
               bundle: %Proto.EMR.MedicationsBundle{
                 id: ^bundle_id,
                 specialist_id: specialist_id,
                 payments_params: %Proto.Generics.PaymentsParams{
                   amount: "299",
                   currency: "AED",
                   transaction_reference: "transaction_reference",
                   payment_method: :TELR
                 }
               },
               specialist: %Proto.Generics.Specialist{
                 id: specialist_id
               }
             } = proto_response(conn, 200, GetMedicationResponse)
    end
  end

  # describe "POST save_payment" do
  #   setup [:proto_content, :authenticate_patient]

  # test "saves medication payment", %{conn: conn, current_patient: current_patient} do
  #   specialist = Authentication.Factory.insert(:verified_specialist)
  #   _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

  #   record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

  #   %{id: bundle_id} =
  #     EMR.Factory.insert(:medications_bundle,
  #       patient_id: current_patient.id,
  #       timeline_id: record.id,
  #       specialist_id: specialist.id,
  #       medications: [
  #         %{
  #           name: "medication 1",
  #           direction: "dir 1",
  #           quantity: "1",
  #           refills: 1
  #         }
  #       ]
  #     )

  #   proto =
  #     %{
  #       payments_params: %{
  #         amount: "299",
  #         currency: "AED",
  #         transaction_reference: "transaction_reference",
  #         payment_method: :TELR
  #       }
  #     }
  #     |> SaveMedicationPayments.new()
  #     |> SaveMedicationPayments.encode()

  #   conn = post(conn, emr_medications_path(conn, :save_payment, record.id, bundle_id), proto)
  #   IO.inspect(conn, label: "conn.....")
  #   assert response(conn, 200)

  #   assert %EMR.Medications.Payment{
  #            id: _,
  #            medications_bundle_id: ^bundle_id,
  #            transaction_reference: "transaction_reference",
  #            payment_method: :TELR,
  #            price: %Money{amount: 299, currency: :AED}
  #          } =
  #            EMR.Medications.Payments.fetch_by_medications_bundle_id(bundle_id)
  # end
  # end
end
