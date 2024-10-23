defmodule Web.PanelApi.TimelineController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  plug Web.Plugs.VerifySpecialistPatientConnection, param_name: "id", via_timeline: true

  @authorize scopes: [
               "GP",
               "NURSE",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def show(conn, %{"id" => timeline_id}) do
    with {:ok, timeline, specialist_ids} <- EMR.fetch_timeline_for_record(timeline_id) do
      specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

      conn
      |> render("show.proto", %{
        timeline: timeline,
        specialists_generic_data: specialists_generic_data
      })
    end
  end
end

defmodule Web.PanelApi.TimelineView do
  use Web, :view

  def render("show.proto", %{
        timeline: timeline,
        specialists_generic_data: specialists_generic_data
      }) do
    %Proto.Timeline.GetTimelineResponse{
      timeline: Web.View.Timeline.render_timeline(timeline),
      deprecated: Enum.map(specialists_generic_data, &Web.View.Timeline.render_specialist/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end
end
