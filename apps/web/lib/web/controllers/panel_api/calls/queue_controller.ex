defmodule Web.PanelApi.Calls.QueueController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def pending_nurse_to_gp_calls(conn, _params) do
    {:ok, pending_calls} = Calls.fetch_pending_nurse_to_gp_calls()

    nurse_ids = Enum.map(pending_calls, & &1.nurse_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(nurse_ids)

    specialists_generic_data_map =
      Map.new(specialists_generic_data, fn specialist_generic_data ->
        {specialist_generic_data.specialist.id, specialist_generic_data}
      end)

    pending_calls =
      Enum.map(pending_calls, fn queue_entry ->
        %{nurse_id: nurse_id, patient_id: patient_id, record_id: record_id} = queue_entry

        %{
          nurse: specialists_generic_data_map[nurse_id],
          patient_id: patient_id,
          record_id: record_id
        }
      end)

    conn |> render("pending_nurse_to_gp_calls.proto", %{pending_calls: pending_calls})
  end

  @authorize scope: "EXTERNAL"
  def doctor_category_invitations(conn, params) do
    category_id = params["category_id"] |> String.to_integer()
    specialist_id = conn.assigns.current_specialist_id

    {:ok, invitations} = Calls.fetch_doctor_category_invitations(specialist_id, category_id)

    specialist_ids = Enum.map(invitations, & &1.invited_by_specialist_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    specialists_generic_data_map =
      Map.new(specialists_generic_data, fn specialist_generic_data ->
        {specialist_generic_data.specialist.id, specialist_generic_data}
      end)

    invitations =
      Enum.map(invitations, fn invitation ->
        %{invited_by_specialist_id: specialist_id} = invitation

        %{
          invited_by: specialists_generic_data_map[specialist_id],
          call_id: invitation.call_id,
          patient_id: invitation.patient_id,
          record_id: invitation.record_id,
          sent_at: invitation.inserted_at
        }
      end)

    conn
    |> render("doctor_category_invitations.proto", %{
      category_id: category_id,
      doctor_category_invitations: invitations
    })
  end

  @doc """
  Patients' queue with Proto.Calls.PatientsQueueEntry response.
  To be deleted after frontend changes used endpoint to v2.
  """
  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def patients_queue(conn, _params) do
    gp_id = conn.assigns.current_specialist_id
    {:ok, patients_queue} = UrgentCare.fetch_patients_queue(gp_id)

    patient_ids_in_queue = Enum.map(patients_queue, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids_in_queue)

    patients_generic_data_map =
      Map.new(patients_generic_data, fn data -> {data.patient_id, data} end)

    patients_queue =
      Enum.map(patients_queue, fn %{
                                    patient_id: patient_id,
                                    record_id: record_id,
                                    inserted_at: inserted_at
                                  } ->
        %{
          patient: patients_generic_data_map[patient_id],
          record_id: record_id,
          inserted_at: inserted_at
        }
      end)

    render(conn, "patients_queue.proto", %{patients_queue: patients_queue})
  end

  @doc """
  Patients' queue with Proto.Calls.PatientsQueueEntryV2 response.
  """
  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def patients_queue_v2(conn, _params) do
    gp_id = conn.assigns.current_specialist_id

    patients_queue = Web.PatientsQueueData.get_by_gp_id(gp_id)

    render(conn, "patients_queue_v2.proto", %{patients_queue: patients_queue})
  end
end

defmodule Web.PanelApi.Calls.QueueView do
  use Web, :view

  def render("pending_nurse_to_gp_calls.proto", %{pending_calls: pending_calls}) do
    %Proto.Calls.GetPendingNurseToGPCallsResponse{
      pending_calls: Web.View.Calls.render_pending_nurse_to_gp_calls(pending_calls)
    }
  end

  def render("doctor_category_invitations.proto", %{
        category_id: category_id,
        doctor_category_invitations: invitations
      }) do
    %Proto.Calls.GetDoctorCategoryInvitationsResponse{
      doctor_category_invitations:
        Web.View.Calls.render_doctor_category_invitations(category_id, invitations)
    }
  end

  def render("patients_queue.proto", %{patients_queue: patients_queue}) do
    %Proto.Calls.GetPatientsQueueResponse{
      patients_queue: Web.View.Calls.render_patients_queue(patients_queue)
    }
  end

  def render("patients_queue_v2.proto", %{patients_queue: patients_queue}) do
    %Proto.Calls.GetPatientsQueueResponse{
      patients_queue: Web.View.Calls.render_patients_queue_v2(patients_queue)
    }
  end
end
