defmodule Web.AdminApi.ExternalSpecialists.BasicInfoController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = params["specialist_id"]

    {:ok, basic_info} = SpecialistProfile.fetch_basic_info(specialist_id)

    conn
    |> render("show.proto", %{basic_info: basic_info})
  end
end

defmodule Web.AdminApi.ExternalSpecialists.BasicInfoView do
  use Web, :view

  def render("show.proto", %{basic_info: basic_info}) do
    %Proto.SpecialistProfile.GetBasicInfoResponse{
      basic_info: Web.View.SpecialistProfile.render_basic_info(basic_info)
    }
  end
end
