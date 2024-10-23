defmodule Web.Api.EMR.VisitsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    patient_id = conn.assigns.current_patient_id

    %{"record_id" => record_id} = params
    record_id = String.to_integer(record_id)

    {:ok, visits, next_token} = Visits.fetch_visits_for_record(patient_id, record_id, params)

    conn
    |> render("index.proto", %{
      visits: visits,
      next_token: next_token |> Web.ControllerHelper.next_token_to_string()
    })
  end
end

defmodule Web.Api.EMR.VisitsView do
  use Web, :view

  def render("index.proto", %{visits: visits, next_token: next_token}) do
    %Proto.EMR.GetRecordVisitsResponse{
      visits: Enum.map(visits, &Web.View.Visits.render_emr_visit_data_for_patient/1),
      next_token: next_token
    }
  end
end
