defmodule Web.AdminApi.Specialists.BioController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = String.to_integer(params["specialist_id"])

    bio = SpecialistProfile.get_bio(specialist_id)

    conn
    |> render("show.proto", %{bio: bio})
  end

  @decode Proto.SpecialistProfile.UpdateBioRequest
  def update(conn, params) do
    specialist_id = String.to_integer(params["specialist_id"])
    bio_proto = conn.assigns.protobuf.bio

    params = Web.Parsers.SpecialistProfile.Bio.to_map_params(bio_proto)

    with {:ok, bio} <- SpecialistProfile.update_bio(specialist_id, params) do
      conn
      |> render("update.proto", %{bio: bio})
    end
  end
end

defmodule Web.AdminApi.Specialists.BioView do
  use Web, :view

  def render("show.proto", %{bio: bio}) do
    %Proto.SpecialistProfile.GetBioResponse{
      bio: Web.View.SpecialistProfile.render_bio(bio)
    }
  end

  def render("update.proto", %{bio: bio}) do
    %Proto.SpecialistProfile.UpdateBioResponse{
      bio: Web.View.SpecialistProfile.render_bio(bio)
    }
  end
end
