defmodule Web.AdminApi.InternalSpecialists.BasicInfoController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = params["specialist_id"]

    {:ok, basic_info} = SpecialistProfile.fetch_basic_info(specialist_id)

    conn
    |> render("show.proto", %{basic_info: basic_info})
  end

  @decode Proto.SpecialistProfile.UpdateBasicInfoRequest
  def update(conn, params) do
    specialist_id = params["specialist_id"] |> String.to_integer()
    basic_info_proto = conn.assigns.protobuf.basic_info

    params = Web.Parsers.SpecialistProfile.BasicInfo.to_map_params(basic_info_proto)

    with {:ok, basic_info} <- SpecialistProfile.update_basic_info(params, specialist_id) do
      conn
      |> render("update.proto", %{basic_info: basic_info})
    end
  end
end

defmodule Web.AdminApi.InternalSpecialists.BasicInfoView do
  use Web, :view

  def render("show.proto", %{basic_info: basic_info}) do
    %Proto.SpecialistProfile.GetBasicInfoResponse{
      basic_info: Web.View.SpecialistProfile.render_basic_info(basic_info)
    }
  end

  def render("update.proto", %{basic_info: basic_info}) do
    %Proto.SpecialistProfile.UpdateBasicInfoResponse{
      basic_info: Web.View.SpecialistProfile.render_basic_info(basic_info)
    }
  end
end