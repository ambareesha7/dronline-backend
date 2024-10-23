defmodule Web.PanelApi.Profile.V2.DescriptionController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    bio = SpecialistProfile.get_bio(specialist_id)

    conn
    |> render("show.proto", %{description: bio})
  end

  @decode Proto.SpecialistProfileV2.UpdateProfileDescriptionRequestV2
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    profile_description = Map.from_struct(conn.assigns.protobuf.profile_description)

    with {:ok, bio} <- SpecialistProfile.update_bio(specialist_id, profile_description) do
      conn
      |> render("update.proto", %{description: bio})
    end
  end
end

defmodule Web.PanelApi.Profile.V2.DescriptionView do
  use Web, :view

  def render("show.proto", %{description: description}) do
    %Proto.SpecialistProfileV2.GetProfileDescriptionResponseV2{
      profile_description: Web.View.SpecialistProfileV2.render_description(description)
    }
  end

  def render("update.proto", %{description: description}) do
    %Proto.SpecialistProfileV2.UpdateProfileDescriptionResponseV2{
      profile_description: Web.View.SpecialistProfileV2.render_description(description)
    }
  end
end
