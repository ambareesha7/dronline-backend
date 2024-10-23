defmodule Web.PanelApi.Calls.QueueControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Calls.GetDoctorCategoryInvitationsResponse
  alias Proto.Calls.GetPatientsQueueResponse
  alias Proto.Calls.GetPendingNurseToGPCallsResponse

  alias Proto.Calls.DoctorCategoryInvitations
  alias Proto.Calls.PatientsQueue
  alias Proto.Calls.PendingNurseToGPCalls

  use Mockery

  describe "GET pending_nurse_to_gp_calls" do
    setup [:authenticate_gp]

    test "returns queue of nurses calling to gp", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      _ = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)

      cmd = %Calls.PendingNurseToGPCalls.Commands.CallGP{
        nurse_id: nurse.id,
        record_id: record.id,
        patient_id: patient.id
      }

      :ok = Calls.call_gp_as_nurse(cmd)

      conn = get(conn, panel_calls_queue_path(conn, :pending_nurse_to_gp_calls))

      %GetPendingNurseToGPCallsResponse{
        pending_calls: %PendingNurseToGPCalls{pending_calls: [pending_call]}
      } = proto_response(conn, 200, GetPendingNurseToGPCallsResponse)

      assert pending_call.nurse.id == nurse.id
    end
  end

  describe "GET doctor_category_invitations" do
    setup [:authenticate_external]

    test "returns list of invitations for given category", %{
      conn: conn,
      current_external: specialist
    } do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      patient = PatientProfile.Factory.insert(:patient)
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: nurse.id)
      :ok = add_to_team(team_id: team.id, specialist_id: specialist.id)

      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %Calls.DoctorCategoryInvitations.Commands.InviteCategory{
        invited_by_specialist_id: nurse.id,
        patient_id: patient.id,
        record_id: record.id,
        call_id: UUID.uuid4(),
        session_id: UUID.uuid4(),
        category_id: doctor_category_id
      }

      :ok = Calls.DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      conn =
        get(conn, panel_calls_queue_path(conn, :doctor_category_invitations, doctor_category_id))

      assert %GetDoctorCategoryInvitationsResponse{
               doctor_category_invitations: %DoctorCategoryInvitations{
                 category_id: ^doctor_category_id,
                 invitations: [invitation]
               }
             } = proto_response(conn, 200, GetDoctorCategoryInvitationsResponse)

      assert invitation.invited_by.id == nurse.id
    end
  end

  describe "GET patients_queue" do
    setup [:authenticate_gp]

    test "succeeds", %{conn: conn, current_gp: current_gp} do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      _patient_basic_info = PatientProfile.Factory.insert(:basic_info, %{patient_id: patient_id})

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: current_gp.id)
      Application.put_env(:urgent_care, :default_clinic_id, Integer.to_string(team.id))

      UrgentCare.PatientsQueue.add_to_queue(%{
        patient_id: patient_id,
        record_id: EMR.Factory.insert(:automatic_record, patient_id: patient_id).id,
        patient_location: %{latitude: 10.0, longitude: 10.0},
        device_id: UUID.uuid4(),
        payment_params: %{
          transaction_reference: "transaction_reference",
          payment_method: :TELR,
          amount: "299",
          currency: "USD",
          urgent_care_request_id: UUID.uuid4()
        }
      })

      conn = get(conn, panel_calls_queue_path(conn, :patients_queue))

      %GetPatientsQueueResponse{
        patients_queue: %PatientsQueue{
          patients_queue_entries: [%{patient: %{id: ^patient_id}}]
        }
      } =
        proto_response(conn, 200, GetPatientsQueueResponse)
    end
  end

  describe "GET patients_queue_v2" do
    setup [:authenticate_gp]

    setup %{current_gp: current_gp} do
      patient = PatientProfile.Factory.insert(:patient)
      _patient_basic_info = PatientProfile.Factory.insert(:basic_info, %{patient_id: patient.id})

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: current_gp.id)
      Application.put_env(:urgent_care, :default_clinic_id, Integer.to_string(team.id))

      [patient: patient]
    end

    test "succeeds", %{conn: conn, patient: patient = %{id: patient_id}} do
      Authentication.Patient.Account.create(%{
        main_patient_id: patient_id,
        firebase_id: "firebase_id#{:rand.uniform()}",
        phone_number: patient.phone_number,
        is_signed_up: true
      })

      UrgentCare.PatientsQueue.add_to_queue(%{
        patient_id: patient_id,
        record_id: EMR.Factory.insert(:automatic_record, patient_id: patient_id).id,
        patient_location: %{latitude: 10.0, longitude: 10.0},
        device_id: UUID.uuid4(),
        payment_params: %{
          transaction_reference: "transaction_reference",
          payment_method: :TELR,
          amount: "299",
          currency: "USD",
          urgent_care_request_id: UUID.uuid4()
        }
      })

      conn = get(conn, panel_calls_queue_path(conn, :patients_queue_v2))

      %GetPatientsQueueResponse{
        patients_queue: %PatientsQueue{
          patients_queue_entries_v2: [
            %{patient_id: ^patient_id, is_signed_up: true}
          ]
        }
      } =
        proto_response(conn, 200, GetPatientsQueueResponse)
    end

    test "succeeds when patient has an account without sign up", %{
      conn: conn,
      patient: patient = %{id: patient_id}
    } do
      Authentication.Patient.Account.create(%{
        main_patient_id: patient_id,
        firebase_id: "firebase_id#{:rand.uniform()}",
        phone_number: patient.phone_number,
        is_signed_up: false
      })

      UrgentCare.PatientsQueue.add_to_queue(%{
        patient_id: patient_id,
        record_id: EMR.Factory.insert(:automatic_record, patient_id: patient_id).id,
        patient_location: %{latitude: 10.0, longitude: 10.0},
        device_id: UUID.uuid4(),
        payment_params: %{
          transaction_reference: "transaction_reference",
          payment_method: :TELR,
          amount: "299",
          currency: "USD",
          urgent_care_request_id: UUID.uuid4()
        }
      })

      conn = get(conn, panel_calls_queue_path(conn, :patients_queue_v2))

      %GetPatientsQueueResponse{
        patients_queue: %PatientsQueue{
          patients_queue_entries_v2: [%{patient_id: ^patient_id, is_signed_up: false}]
        }
      } =
        proto_response(conn, 200, GetPatientsQueueResponse)
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp random_id, do: :rand.uniform(1000)
end
