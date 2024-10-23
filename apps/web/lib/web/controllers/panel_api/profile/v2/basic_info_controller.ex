defmodule Web.PanelApi.Profile.V2.BasicInfoController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, basic_info} <- SpecialistProfile.fetch_basic_info(specialist_id, error: true),
         {:ok, location} <- SpecialistProfile.fetch_location(specialist_id) do
      conn
      |> render("show.proto", %{basic_info: basic_info, location: location})
    else
      {:error, :not_found} ->
        conn
        |> render("show.proto", %{basic_info: nil, location: nil})
    end
  end

  @decode Proto.SpecialistProfileV2.UpdateBasicInfoRequestV2
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    basic_info_proto = conn.assigns.protobuf.basic_info

    params = Web.Parsers.SpecialistProfile.BasicInfoV2.to_map_params(basic_info_proto)

    with {:ok, basic_info} <- SpecialistProfile.update_basic_info(params, specialist_id),
         {:ok, location} <- SpecialistProfile.update_location(params.address, specialist_id) do
      conn
      |> render("update.proto", %{basic_info: basic_info, location: location})
    end
  end
end

defmodule Web.PanelApi.Profile.V2.BasicInfoView do
  use Web, :view

  def render("show.proto", %{basic_info: basic_info, location: location}) do
    %Proto.SpecialistProfileV2.GetBasicInfoResponseV2{
      basic_info: Web.View.SpecialistProfileV2.render_basic_info(basic_info, location)
    }
  end

  def render("update.proto", %{basic_info: basic_info, location: location}) do
    %Proto.SpecialistProfile.UpdateBasicInfoResponse{
      basic_info: Web.View.SpecialistProfileV2.render_basic_info(basic_info, location)
    }
  end
end
