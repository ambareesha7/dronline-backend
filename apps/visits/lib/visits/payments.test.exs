defmodule Visits.PaymentsTest do
  use Postgres.DataCase, async: true

  setup do
    patient = PatientProfile.Factory.insert(:patient)
    _ = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

    specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
    _ = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

    {:ok, team} = Teams.create_team(specialist.id, %{})
    :ok = add_to_team(team_id: team.id, specialist_id: specialist.id)

    date = Date.utc_today()
    start_time = DateTime.utc_now() |> Timex.to_unix()

    {:ok, _day_schedule} =
      Visits.DaySchedule.insert_or_update(
        %Visits.DaySchedule{specialist_id: specialist.id, date: date},
        [%{start_time: start_time, visit_type: :ONLINE}],
        []
      )

    cmd = %Visits.Commands.TakeTimeslot{
      specialist_id: specialist.id,
      start_time: start_time,
      patient_id: patient.id,
      chosen_medical_category_id: 1,
      visit_type: :ONLINE
    }

    {:ok, visit} = Visits.take_timeslot(cmd)

    {:ok, visit: visit, patient: patient, specialist: specialist, team: team, date: date}
  end

  describe "create/1" do
    test "creates payment", %{
      visit: %{record_id: visit_record_id},
      patient: %{id: patient_id},
      specialist: %{id: specialist_id},
      team: %{id: team_id}
    } do
      assert {:ok,
              %Visits.Visit.Payment{
                visit_id: ^visit_record_id,
                patient_id: ^patient_id,
                specialist_id: ^specialist_id,
                team_id: ^team_id,
                transaction_reference: "abc123",
                payment_method: :telr,
                price: %Money{amount: 10000, currency: :USD}
              }} =
               Visits.Payments.create(%{
                 visit_id: visit_record_id,
                 patient_id: patient_id,
                 specialist_id: specialist_id,
                 team_id: team_id,
                 transaction_reference: "abc123",
                 payment_method: "telr",
                 amount: "10000",
                 currency: "USD"
               })
    end

    test "doesn't create payment without required fields" do
      assert {:error,
              %Ecto.Changeset{
                changes: %{price: %Money{amount: 0, currency: :USD}},
                errors: [
                  visit_id: {"can't be blank", [validation: :required]},
                  patient_id: {"can't be blank", [validation: :required]},
                  specialist_id: {"can't be blank", [validation: :required]},
                  payment_method: {"can't be blank", [validation: :required]}
                ],
                valid?: false
              }} = Visits.Payments.create(%{})
    end

    test "allow only listed payment methods", %{
      visit: %{record_id: visit_record_id},
      patient: %{id: patient_id},
      specialist: %{id: specialist_id},
      team: %{id: team_id}
    } do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  payment_method:
                    {"is invalid",
                     [
                       type:
                         {:parameterized, Ecto.Enum,
                          %{
                            embed_as: :self,
                            mappings: [telr: "telr", external: "external"],
                            on_cast: %{"external" => :external, "telr" => :telr},
                            on_dump: %{external: "external", telr: "telr"},
                            on_load: %{"external" => :external, "telr" => :telr},
                            type: :string
                          }},
                       validation: :cast
                     ]}
                ],
                valid?: false
              }} =
               Visits.Payments.create(%{
                 visit_id: visit_record_id,
                 patient_id: patient_id,
                 specialist_id: specialist_id,
                 team_id: team_id,
                 transaction_reference: "abc123",
                 payment_method: "stripe",
                 amount: "10000",
                 currency: "USD"
               })
    end

    test "sets to USD if currency is empty string", %{
      visit: %{record_id: visit_record_id},
      patient: %{id: patient_id},
      specialist: %{id: specialist_id},
      team: %{id: team_id}
    } do
      assert {:ok,
              %Visits.Visit.Payment{
                visit_id: ^visit_record_id,
                patient_id: ^patient_id,
                specialist_id: ^specialist_id,
                team_id: ^team_id,
                transaction_reference: "abc123",
                payment_method: :telr,
                price: %Money{amount: 10000, currency: :USD}
              }} =
               Visits.Payments.create(%{
                 visit_id: visit_record_id,
                 patient_id: patient_id,
                 specialist_id: specialist_id,
                 team_id: team_id,
                 transaction_reference: "abc123",
                 payment_method: "telr",
                 amount: "10000",
                 currency: ""
               })
    end
  end

  describe "refund/1" do
    setup %{
      visit: %{record_id: visit_record_id},
      patient: %{id: patient_id},
      specialist: %{id: specialist_id},
      team: %{id: team_id}
    } do
      {:ok, payment} =
        Visits.Payments.create(%{
          visit_id: visit_record_id,
          patient_id: patient_id,
          specialist_id: specialist_id,
          team_id: team_id,
          transaction_reference: "abc123",
          amount: "10000",
          currency: "USD",
          payment_method: "external"
        })

      {:ok, payment: payment}
    end

    test "creates refund", %{payment: %{id: payment_id}, patient: %{id: patient_id}} do
      assert {:ok,
              %Visits.Visit.Payment.Refund{
                payment_id: ^payment_id,
                requested_by: :patient,
                requester_id: ^patient_id
              }} =
               Visits.Payments.refund(%{
                 payment_id: payment_id,
                 requested_by: :patient,
                 requester_id: patient_id
               })
    end

    test "doesn't create refund without required fields" do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  payment_id: {"can't be blank", [validation: :required]},
                  requested_by: {"can't be blank", [validation: :required]},
                  requester_id: {"can't be blank", [validation: :required]}
                ],
                valid?: false
              }} = Visits.Payments.refund(%{})
    end
  end

  describe "fetch_refund_record_id/1" do
    setup %{
      visit: %{record_id: visit_record_id},
      patient: %{id: patient_id},
      specialist: %{id: specialist_id},
      team: %{id: team_id}
    } do
      {:ok, payment} =
        Visits.Payments.create(%{
          visit_id: visit_record_id,
          patient_id: patient_id,
          specialist_id: specialist_id,
          team_id: team_id,
          transaction_reference: "abc123",
          amount: "10000",
          currency: "USD",
          payment_method: "external"
        })

      {:ok, payment: payment}
    end

    test "returns refund based on record_id", %{
      visit: %{record_id: record_id},
      payment: %{id: payment_id},
      patient: %{id: patient_id}
    } do
      {:ok, _refund} =
        Visits.Payments.refund(%{
          payment_id: payment_id,
          requested_by: :patient,
          requester_id: patient_id
        })

      assert {:ok,
              %Visits.Visit.Payment.Refund{
                requested_by: :patient,
                payment: %Visits.Visit.Payment{visit_id: ^record_id}
              }} =
               Visits.Payments.fetch_refund_record_id(record_id)
    end
  end

  describe "fetch_by_record_and_patient_id/2" do
    test "returns proper record for Urgent Care type of medical asistance ", %{
      patient: %{id: patient_id}
    } do
      emr_record = EMR.Factory.insert(:automatic_record, patient_id: patient_id)

      %UrgentCare.PatientsQueue.Schema{} =
        UrgentCare.PatientsQueue.add_to_queue(%{
          patient_id: patient_id,
          record_id: emr_record.id,
          patient_location: %{latitude: 10.0, longitude: 10.0},
          device_id: "123",
          payment_params: %{
            transaction_reference: "transaction_reference",
            payment_method: :TELR,
            amount: "299",
            currency: "USD",
            urgent_care_request_id: UUID.uuid4()
          }
        })

      assert(
        {:ok,
         %UrgentCare.Payments.Payment{
           transaction_reference: "transaction_reference",
           payment_method: :telr,
           price: %Money{amount: 299, currency: :USD}
         }} = Visits.Payments.fetch_by_record_and_patient_id(emr_record.id, patient_id)
      )
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
