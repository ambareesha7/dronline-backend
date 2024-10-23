defmodule Web.Api.EMR.SpecialistsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    record_id = params["record_id"]

    with {:ok, _timeline, specialist_ids} <- EMR.fetch_timeline_for_record(record_id) do
      specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

      conn |> render("index.proto", %{specialists_generic_data: specialists_generic_data})
    end
  end
end

defmodule Web.Api.EMR.SpecialistsView do
  use Web, :view

  def render("index.proto", %{specialists_generic_data: specialists_generic_data}) do
    %Proto.EMR.GetRecordSpecialistsResponse{
      deprecated: Enum.map(specialists_generic_data, &Web.View.EMR.render_specialist/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end
end
