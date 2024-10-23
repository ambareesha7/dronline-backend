defmodule Web.PanelApi.EMR.ProceduresController do
  use Web, :controller

  plug Web.Plugs.RequireOnboarding

  action_fallback Web.FallbackController

  alias EMR.Procedures

  def index(conn, params) do
    specialist_id = conn.assigns.current_specialist_id
    params = Procedures.decode_next_token(params)

    with {:ok, medical_summaries, next_token} <-
           Procedures.get_for_specialist(specialist_id, params) do
      specialists_generic_data =
        medical_summaries
        |> Enum.map(& &1.specialist_id)
        |> Enum.uniq()
        |> Web.SpecialistGenericData.get_by_ids()

      patients_generic_data =
        medical_summaries
        |> Enum.map(& &1.timeline.patient_id)
        |> Enum.uniq()
        |> Web.PatientGenericData.get_by_ids()

      render(conn, "index.proto", %{
        medical_summaries: medical_summaries,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      })
    end
  end
end

defmodule Web.PanelApi.EMR.ProceduresView do
  use Web, :view

  alias EMR.Procedures

  def render("index.proto", %{
        medical_summaries: medical_summaries,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      }) do
    %Proto.EMR.GetProceduresResponse{
      bundles: Enum.map(medical_summaries, &Web.View.EMR.render_procedures_bundle/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1),
      next_token: Procedures.encode_next_token(next_token)
    }
  end
end
