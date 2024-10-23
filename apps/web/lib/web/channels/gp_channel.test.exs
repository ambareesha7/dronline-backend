defmodule Web.GPChannelTest do
  use Mockery
  use Web.ChannelCase, async: false

  alias Web.GPChannel

  alias Proto.Channels.SocketMessage.ChannelPayload

  describe "join/3" do
    test "with valid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} = subscribe_and_join(socket, GPChannel, "gp")
    end

    test "with invalid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :NURSE})

      assert {:error, %{}} = subscribe_and_join(socket, GPChannel, "gp")
    end
  end

  test "PING-PONG temporary events" do
    socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})
    {:ok, _join_payload, socket} = subscribe_and_join(socket, GPChannel, "gp")

    payload = "ping text"

    ref = push(socket, "ping", payload)
    assert_reply(ref, :ok)
    assert_push("pong", _payload)
  end

  describe "handle_in" do
    test "start_call from patient" do
      gp = Authentication.Factory.insert(:specialist, type: "GP")

      %{patient_id: patient_id} = add_patient_to_queue()

      socket = socket(Web.Socket, 0, %{current_specialist_id: gp.id, type: :GP})
      {:ok, _join_payload, socket} = subscribe_and_join(socket, GPChannel, "gp")

      payload = %Proto.Calls.StartCall{
        caller_id: patient_id
      }

      ref = push(socket, "start_call", payload)
      assert_reply(ref, :ok)
    end

    test "answer_call_from_nurse" do
      gp = Authentication.Factory.insert(:specialist, type: "GP")

      socket = socket(Web.Socket, 0, %{current_specialist_id: gp.id, type: :GP})
      {:ok, _join_payload, socket} = subscribe_and_join(socket, GPChannel, "gp")

      payload = %Proto.Calls.AnswerCallFromNurse{
        nurse_id: Authentication.Factory.insert(:specialist, type: "NURSE").id
      }

      ref = push(socket, "answer_call_from_nurse", payload)
      assert_reply(ref, :ok)
    end

    test "patients_queue_update" do
      gp = Authentication.Factory.insert(:specialist, type: "GP")

      {:ok, team} = Teams.create_team(:rand.uniform(1000), %{})
      :ok = Teams.add_to_team(team_id: team.id, specialist_id: gp.id)
      Teams.accept_invitation(team_id: team.id, specialist_id: gp.id)
      Application.put_env(:urgent_care, :default_clinic_id, Integer.to_string(team.id))

      %{patient_id: patient_id} = add_patient_to_queue()

      socket = socket(Web.Socket, 0, %{current_specialist_id: gp.id, type: :GP})
      {:ok, _join_payload, socket} = subscribe_and_join(socket, GPChannel, "gp")

      _ref = broadcast_from(socket, "patients_queue_update", %{})

      assert_push("patients_queue_update", %{
        proto: %Proto.Calls.PatientsQueue{
          patients_queue_entries_v2: [
            %Proto.Calls.PatientsQueueEntryV2{
              patient_id: ^patient_id,
              is_signed_up: true
            }
          ]
        }
      })
    end
  end

  defp add_patient_to_queue do
    patient = PatientProfile.Factory.insert(:patient)
    _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

    Authentication.Patient.Account.create(%{
      main_patient_id: patient.id,
      firebase_id: "firebase_id#{:rand.uniform()}",
      phone_number: patient.phone_number,
      is_signed_up: true
    })

    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
    location = %{latitude: 10.0, longitude: 10.0}
    device_id = UUID.uuid4()
    {:ok, specialist_team} = Teams.create_team(2, %{})

    team_ids = [specialist_team.id]
    mock(UrgentCare.AreaDispatch, [team_ids_in_area: 1], team_ids)

    UrgentCare.PatientsQueue.add_to_queue(%{
      patient_id: patient.id,
      record_id: record.id,
      patient_location: location,
      device_id: device_id,
      payment_params: %{
        transaction_reference: "transaction_reference",
        payment_method: :TELR,
        amount: "299",
        currency: "USD",
        urgent_care_request_id: UUID.uuid4()
      }
    })
  end
end
