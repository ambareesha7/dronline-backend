defmodule Web.Api.EMR.MedicalSummariesController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    record_id = params["record_id"]

    with {:ok, medical_summaries} <- EMR.fetch_medical_summaries(record_id) do
      specialists_generic_data =
        medical_summaries
        |> Enum.map(& &1.specialist_id)
        |> Web.SpecialistGenericData.get_by_ids()

      render(conn, "index.proto", %{
        medical_summaries: medical_summaries,
        specialists_generic_data: specialists_generic_data
      })
    end
  end

  def show(conn, params) do
    # TODO: check if the record is for current patient
    medical_summary_id = String.to_integer(params["id"])

    with {:ok, medical_summary} <- EMR.fetch_medical_summary(medical_summary_id),
         specialist_generic_data <-
           Web.SpecialistGenericData.get_by_id(medical_summary.specialist_id) do
      render(conn, "show.proto", %{
        medical_summary: medical_summary,
        specialist: specialist_generic_data
      })
    end
  end
end

defmodule Web.Api.EMR.MedicalSummariesView do
  use Web, :view

  def render("index.proto", %{
        medical_summaries: medical_summaries,
        specialists_generic_data: specialists_generic_data
      }) do
    %Proto.EMR.GetMedicalSummariesResponse{
      medical_summaries:
        Enum.map(
          medical_summaries,
          &Web.View.EMR.render_medical_summary/1
        ),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("show.proto", %{medical_summary: medical_summary, specialist: specialist}) do
    %Proto.EMR.GetMedicalSummaryResponse{
      medical_summary: Web.View.EMR.render_medical_summary(medical_summary),
      specialist: Web.View.Generics.render_specialist(specialist)
    }
  end
end
