defmodule Web.Api.Specialists.BioController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = String.to_integer(params["specialist_id"])

    bio = SpecialistProfile.get_bio(specialist_id)

    conn
    |> render("show.proto", %{bio: bio})
  end
end

defmodule Web.Api.Specialists.BioView do
  use Web, :view

  def render("show.proto", %{bio: bio}) do
    %Proto.SpecialistProfile.GetBioResponse{
      bio: Web.View.SpecialistProfile.render_bio(bio)
    }
  end
end
