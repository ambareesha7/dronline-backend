defmodule Web.ChannelBroadcastWorkerTest do
  use Web.ChannelCase, async: true

  use Mockery

  @name :channel_broadcast_worker

  defp verify_protobuf!(%mod{} = protobuf) do
    mod.encode(protobuf)
  end

  defp timeout, do: 5000

  defp create_pending_dispatch do
    patient = PatientProfile.Factory.insert(:patient)
    gp = Authentication.Factory.insert(:specialist, type: "GP")
    _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: gp.id)
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    patient_location_address = %{
      city: "Dubai",
      country: "United Arab Emirates",
      building_number: "1",
      postal_code: "2",
      street_name: "3"
    }

    cmd = %Triage.Commands.RequestDispatchToPatient{
      patient_id: patient.id,
      patient_location_address: patient_location_address,
      record_id: record.id,
      region: "united-arab-emirates-dubai",
      request_id: UUID.uuid4(),
      requester_id: gp.id
    }

    Triage.request_dispatch_to_patient(cmd)
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
    device_id = UUID.uuid4()
    {:ok, specialist_team} = Teams.create_team(2, %{})

    Application.put_env(:urgent_care, :default_clinic_id, Integer.to_string(specialist_team.id))

    UrgentCare.PatientsQueue.add_to_queue(%{
      patient_id: patient.id,
      record_id: record.id,
      device_id: device_id,
      payment_params: %{
        transaction_reference: "transaction_reference",
        payment_method: :TELR,
        amount: "299",
        currency: "USD",
        urgent_care_request_id: UUID.uuid4()
      }
    })

    {patient, record, specialist_team}
  end

  defp add_category_invitation do
    patient = PatientProfile.Factory.insert(:patient)
    _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    specialist = Authentication.Factory.insert(:verified_specialist)
    {:ok, team} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team.id, specialist_id: specialist.id)

    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

    Calls.DoctorCategoryInvitations.invite_category(%{
      team_id: team.id,
      call_id: "call_id",
      session_id: "session_id",
      invited_by_specialist_id: specialist.id,
      patient_id: patient.id,
      record_id: record.id,
      category_id: 0
    })

    {patient, record, team.id}
  end

  defp create_timeline_item do
    patient = PatientProfile.Factory.insert(:patient)
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
    specialist = Authentication.Factory.insert(:verified_specialist)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

    medical_category = SpecialistProfile.Factory.insert(:medical_category)
    _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

    cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
      patient_id: patient.id,
      record_id: record.id,
      specialist_id: specialist.id
    }

    {:ok, call_item} = EMR.create_call_timeline_item(cmd)

    call_item
  end

  describe "handle_cast :pending_dispatches_update" do
    test "broadcasts pending_dispatches_update event to nurse channels" do
      {:ok, pending_dispatch} = create_pending_dispatch()

      Ecto.Adapters.SQL.Sandbox.allow(
        Postgres.Repo,
        self(),
        Process.whereis(:channel_broadcast_worker)
      )

      Web.Endpoint.subscribe("nurse")

      GenServer.cast(@name, :pending_dispatches_update)
      assert_broadcast("pending_dispatches_update", %{proto: proto}, timeout())

      assert %Proto.Dispatches.PendingDispatchesUpdate{
               dispatches: [fetched_dispatch],
               patients: [fetched_patient],
               specialists: [fetched_specialist]
             } = proto

      assert Map.from_struct(fetched_dispatch.patient_location.address) ==
               Map.from_struct(pending_dispatch.patient_location_address)

      assert fetched_patient.id == pending_dispatch.patient_id
      assert fetched_specialist.id == pending_dispatch.requester_id

      assert verify_protobuf!(proto)
    end
  end

  describe "handle_cast :patients_queue_update" do
    test "broadcasts patients_queue_update event to gp channels" do
      {patient, record, specialist_team} = add_patient_to_queue()

      gp = Authentication.Factory.insert(:specialist, type: "GP")
      :ok = add_to_team(team_id: specialist_team.id, specialist_id: gp.id)

      socket = socket(Web.Socket, 0, %{current_specialist_id: gp.id, type: :GP})
      {:ok, _payload, socket} = subscribe_and_join(socket, Web.GPChannel, "gp")

      Ecto.Adapters.SQL.Sandbox.allow(
        Postgres.Repo,
        self(),
        socket.channel_pid
      )

      GenServer.cast(@name, :patients_queue_update)

      assert_push("patients_queue_update", %{proto: proto}, timeout())

      assert %Proto.Calls.PatientsQueue{
               patients_queue_entries_v2: [fetched_entry]
             } = proto

      assert fetched_entry.patient_id == patient.id
      assert fetched_entry.record_id == record.id

      assert verify_protobuf!(proto)
    end
  end

  describe "handle_cast :doctor_category_invitations_update" do
    test "broadcasts doctor_category_invitations_update event to doctor channels" do
      {patient, record, team_id} = add_category_invitation()

      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      :ok = add_to_team(team_id: team_id, specialist_id: specialist.id)

      Ecto.Adapters.SQL.Sandbox.allow(
        Postgres.Repo,
        self(),
        Process.whereis(:channel_broadcast_worker)
      )

      socket = socket(Web.Socket, 0, %{current_specialist_id: specialist.id, type: :EXTERNAL})
      {:ok, _payload, _socket} = subscribe_and_join(socket, Web.DoctorChannel, "external")

      GenServer.cast(@name, {:doctor_category_invitations_update, 0})
      assert_push("doctor_category_invitations_update", %{proto: proto}, timeout())

      assert %Proto.Calls.DoctorCategoryInvitations{
               category_id: 0,
               invitations: [fetched_entry]
             } = proto

      assert fetched_entry.patient_id == patient.id
      assert fetched_entry.record_id == record.id

      assert verify_protobuf!(proto)
    end
  end

  describe "handle_cast :new_timeline_item" do
    test "broadcasts new_timeline_item event to record channels" do
      timeline_item = create_timeline_item()
      topic = "record:" <> to_string(timeline_item.timeline_id)

      Ecto.Adapters.SQL.Sandbox.allow(
        Postgres.Repo,
        self(),
        Process.whereis(:channel_broadcast_worker)
      )

      Web.Endpoint.subscribe(topic)

      GenServer.cast(@name, {:new_timeline_item, timeline_item})
      assert_broadcast("new_timeline_item", %{proto: proto}, timeout())

      assert verify_protobuf!(proto)
    end
  end

  describe "handle_cast :new_timeline_item_comment" do
    test "broadcasts new_timeline_item_comment event to record channels" do
      gp = Authentication.Factory.insert(:specialist, type: "GP")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: gp.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateItemComment{
        body: "TEST COMMENT",
        commented_by_specialist_id: gp.id,
        commented_on: "HPI",
        patient_id: 1,
        record_id: 1,
        timeline_item_id: UUID.uuid4()
      }

      {:ok, comment, updated_comments_counter} =
        EMR.PatientRecords.Timeline.Item.Comment.create(cmd)

      Ecto.Adapters.SQL.Sandbox.allow(
        Postgres.Repo,
        self(),
        Process.whereis(:channel_broadcast_worker)
      )

      Web.Endpoint.subscribe("record:1")

      GenServer.cast(@name, {:new_timeline_item_comment, comment, updated_comments_counter})
      assert_broadcast("new_timeline_item_comment", %{proto: proto}, timeout())

      assert verify_protobuf!(proto)
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp random_id, do: :rand.uniform(1000)
end
