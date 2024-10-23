defmodule Web.PanelApi.Profile.V2.EducationController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    bio = SpecialistProfile.get_bio(specialist_id)

    conn
    |> render("show.proto", %{education: bio})
  end

  @decode Proto.SpecialistProfileV2.UpdateEducationRequestV2
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    education = Enum.map(conn.assigns.protobuf.education, &Map.from_struct/1)

    with {:ok, bio} <- SpecialistProfile.update_bio(specialist_id, %{education: education}) do
      conn
      |> render("update.proto", %{education: bio})
    end
  end
end

defmodule Web.PanelApi.Profile.V2.EducationView do
  use Web, :view

  def render("show.proto", %{education: education}) do
    %Proto.SpecialistProfileV2.GetEducationResponseV2{
      education: Web.View.SpecialistProfileV2.render_education(education)
    }
  end

  def render("update.proto", %{education: education}) do
    %Proto.SpecialistProfileV2.UpdateEducationResponseV2{
      education: Web.View.SpecialistProfileV2.render_education(education)
    }
  end
end
