defmodule Web.PanelApi.DispatchesController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  @authorize scopes: ["GP", {"EXTERNAL", "PLATINUM"}]
  @decode Proto.Dispatches.RequestDispatchToPatientRequest
  def request_dispatch_to_patient(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    protobuf = conn.assigns.protobuf

    with {:ok, region} <- Triage.determine_region(protobuf.patient_location.address),
         cmd = create_request_cmd(protobuf, specialist_id, region),
         {:ok, _} <- Triage.request_dispatch_to_patient(cmd) do
      conn |> send_resp(200, "")
    end
  end

  defp create_request_cmd(protobuf, specialist_id, region) do
    %Triage.Commands.RequestDispatchToPatient{
      patient_id: protobuf.patient_id,
      patient_location_address: protobuf.patient_location.address |> Map.from_struct(),
      record_id: protobuf.record_id,
      region: region,
      request_id: UUID.uuid4(),
      requester_id: specialist_id
    }
  end

  @authorize scope: "NURSE"
  def pending_dispatches(conn, _params) do
    {:ok, pending_dispatches} = Triage.fetch_pending_dispatches()

    specialist_ids = Enum.map(pending_dispatches, & &1.requester_id)
    patient_ids = Enum.map(pending_dispatches, & &1.patient_id)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    conn
    |> render("pending_dispatches.proto", %{
      dispatches: pending_dispatches,
      specialists_generic_data: specialists_generic_data,
      patients_generic_data: patients_generic_data
    })
  end

  @authorize scope: "NURSE"
  def take_pending_dispatch(conn, params) do
    %{"request_id" => request_id} = params
    nurse_id = conn.assigns.current_specialist_id

    cmd = %Triage.Commands.TakePendingDispatch{nurse_id: nurse_id, request_id: request_id}

    with {:ok, _} <- Triage.take_pending_dispatch(cmd) do
      {:ok, dispatch} = Triage.fetch_ongoing_dispatch_for_nurse(nurse_id)

      specialist_generic_data = Web.SpecialistGenericData.get_by_id(dispatch.requester_id)
      patient_generic_data = Web.PatientGenericData.get_by_id(dispatch.patient_id)

      conn
      |> render("take_pending_dispatch.proto", %{
        dispatch: dispatch,
        specialist_generic_data: specialist_generic_data,
        patient_generic_data: patient_generic_data
      })
    end
  end

  @authorize scope: "NURSE"
  def ongoing_dispatch(conn, _params) do
    nurse_id = conn.assigns.current_specialist_id

    nurse_id
    |> Triage.fetch_ongoing_dispatch_for_nurse()
    |> render_ongoing_dispatch(conn)
  end

  defp render_ongoing_dispatch({:ok, dispatch}, conn) do
    specialist_generic_data = Web.SpecialistGenericData.get_by_id(dispatch.requester_id)
    patient_generic_data = Web.PatientGenericData.get_by_id(dispatch.patient_id)

    conn
    |> render("ongoing_dispatch.proto", %{
      dispatch: dispatch,
      specialist_generic_data: specialist_generic_data,
      patient_generic_data: patient_generic_data
    })
  end

  defp render_ongoing_dispatch({:error, :not_found}, conn) do
    conn |> render("ongoing_dispatch.proto", %{dispatch: nil})
  end

  @authorize scope: "NURSE"
  def end_dispatch(conn, params) do
    %{"request_id" => request_id} = params
    nurse_id = conn.assigns.current_specialist_id

    cmd = %Triage.Commands.EndDispatch{nurse_id: nurse_id, request_id: request_id}

    with {:ok, _} <- Triage.end_dispatch(cmd) do
      conn |> send_resp(200, "")
    end
  end

  @authorize scope: "GP"
  def current_dispatches(conn, _params) do
    {:ok, current_dispatches} = Triage.fetch_current_dispatches()

    nurse_ids = Enum.map(current_dispatches, & &1.nurse_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(nurse_ids)

    conn
    |> render("current_dispatches.proto", %{
      dispatches: current_dispatches,
      specialists_generic_data: specialists_generic_data
    })
  end

  @authorize scope: "GP"
  def ended_dispatches(conn, params) do
    {:ok, ended_dispatches, next_token} = Triage.fetch_ended_dispatches(params)
    total_count = Triage.get_ended_dispatches_total_count()

    nurse_ids = Enum.map(ended_dispatches, & &1.nurse_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(nurse_ids)

    conn
    |> render("ended_dispatches.proto", %{
      dispatches: ended_dispatches,
      next_token: next_token,
      total_count: total_count,
      specialists_generic_data: specialists_generic_data
    })
  end

  @authorize scope: "GP"
  def details(conn, params) do
    %{"request_id" => request_id} = params

    with {:ok, dispatch} <- Triage.fetch_dispatch_by_request_id(request_id) do
      specialist_generic_data = Web.SpecialistGenericData.get_by_id(dispatch.requester_id)
      patient_generic_data = Web.PatientGenericData.get_by_id(dispatch.patient_id)

      conn
      |> render("details.proto", %{
        dispatch: dispatch,
        specialist_generic_data: specialist_generic_data,
        patient_generic_data: patient_generic_data
      })
    end
  end
end

defmodule Web.PanelApi.DispatchesView do
  use Web, :view

  def render("pending_dispatches.proto", %{
        dispatches: dispatches,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data
      }) do
    %Proto.Dispatches.GetPendingDispatchesResponse{
      dispatches: Enum.map(dispatches, &Web.View.Dispatches.render_dispatch/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }
  end

  def render("take_pending_dispatch.proto", %{
        dispatch: dispatch,
        specialist_generic_data: specialist_generic_data,
        patient_generic_data: patient_generic_data
      }) do
    %Proto.Dispatches.TakePendingDispatchResponse{
      dispatch: Web.View.Dispatches.render_dispatch(dispatch),
      specialist: Web.View.Generics.render_specialist(specialist_generic_data),
      patient: Web.View.Generics.render_patient(patient_generic_data)
    }
  end

  def render("ongoing_dispatch.proto", %{dispatch: nil}) do
    %Proto.Dispatches.GetOngoingDispatchResponse{}
  end

  def render("ongoing_dispatch.proto", %{
        dispatch: dispatch,
        specialist_generic_data: specialist_generic_data,
        patient_generic_data: patient_generic_data
      }) do
    %Proto.Dispatches.GetOngoingDispatchResponse{
      dispatch: Web.View.Dispatches.render_dispatch(dispatch),
      specialist: Web.View.Generics.render_specialist(specialist_generic_data),
      patient: Web.View.Generics.render_patient(patient_generic_data)
    }
  end

  def render("current_dispatches.proto", %{
        dispatches: dispatches,
        specialists_generic_data: specialists_generic_data
      }) do
    %Proto.Dispatches.GetCurrentDispatchesResponse{
      detailed_dispatches: Enum.map(dispatches, &Web.View.Dispatches.render_detailed_dispatch/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("ended_dispatches.proto", %{
        dispatches: dispatches,
        next_token: next_token,
        total_count: total_count,
        specialists_generic_data: specialists_generic_data
      }) do
    %Proto.Dispatches.GetEndedDispatchesResponse{
      detailed_dispatches: Enum.map(dispatches, &Web.View.Dispatches.render_detailed_dispatch/1),
      next_token: next_token,
      total_count: total_count,
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("details.proto", %{
        dispatch: dispatch,
        specialist_generic_data: specialist_generic_data,
        patient_generic_data: patient_generic_data
      }) do
    %Proto.Dispatches.GetDispatchDetailsResponse{
      detailed_dispatch: Web.View.Dispatches.render_detailed_dispatch(dispatch),
      specialist: Web.View.Generics.render_specialist(specialist_generic_data),
      patient: Web.View.Generics.render_patient(patient_generic_data)
    }
  end
end
