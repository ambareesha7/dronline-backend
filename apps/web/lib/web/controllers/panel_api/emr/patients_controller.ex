defmodule Web.PanelApi.EMR.PatientsController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  plug Web.Plugs.AssignQuerySpecialistId, [] when action in [:index_connected_to_team_member]

  @authorize scopes: ["GP", "NURSE", {"EXTERNAL", "GOLD"}, {"EXTERNAL", "PLATINUM"}]
  @decode Proto.EMR.CreatePatientRequest
  def create(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    firebase_token = conn.assigns.protobuf.firebase_token

    with {:ok, auth_token_entry} <- Authentication.login_patient(firebase_token),
         {:ok, _connection} <-
           EMR.register_interaction_between(specialist_id, auth_token_entry.patient_id) do
      conn |> render("create.proto", %{patient_id: auth_token_entry.patient_id})
    end
  end

  @authorize scopes: ["GP", "NURSE"]
  def index(conn, params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, patients, next_token} = EMR.fetch_patients_list(specialist_id, params)
    patients_ids = Enum.map(patients, & &1.id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patients_ids)

    conn
    |> render("index.proto", %{
      patients_generic_data: patients_generic_data,
      next_token: next_token |> Web.ControllerHelper.next_token_to_string()
    })
  end

  @authorize scopes: [{"EXTERNAL", "GOLD"}, {"EXTERNAL", "PLATINUM"}]
  def index_connected(conn, params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, patients, next_token} = EMR.fetch_connected_patients_list(specialist_id, params)
    patients_ids = Enum.map(patients, & &1.id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patients_ids)

    conn
    |> render("index.proto", %{
      patients_generic_data: patients_generic_data,
      next_token: next_token |> Web.ControllerHelper.next_token_to_string()
    })
  end

  @authorize scopes: ["GP", "EXTERNAL"]
  def index_connected_to_team_member(conn, params) do
    specialist_id = conn.assigns.query_specialist_id

    {:ok, patients, next_token} = EMR.fetch_patients_list(specialist_id, params)

    patients_ids =
      patients
      |> Enum.map(& &1.id)
      |> Enum.uniq()

    patients_generic_data = Web.PatientGenericData.get_by_ids(patients_ids)

    conn
    |> render("index.proto", %{
      patients_generic_data: patients_generic_data,
      next_token: next_token |> Web.ControllerHelper.next_token_to_string()
    })
  end
end

defmodule Web.PanelApi.EMR.PatientsView do
  use Web, :view

  def render("create.proto", %{patient_id: patient_id}) do
    %{
      patient_id: patient_id
    }
    |> Proto.validate!(Proto.EMR.CreatePatientResponse)
    |> Proto.EMR.CreatePatientResponse.new()
  end

  def render("index.proto", %{
        patients_generic_data: patients_generic_data,
        next_token: next_token
      }) do
    %Proto.EMR.GetPatientsResponse{
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1),
      next_token: next_token
    }
  end
end
