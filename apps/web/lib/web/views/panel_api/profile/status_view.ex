defmodule Web.PanelApi.Profile.StatusView do
  use Web, :view

  def render("show.proto", %{status: status}) do
    %{
      status: render_one(status, Proto.SpecialistProfileView, "status.proto", as: :status)
    }
    |> Proto.validate!(Proto.SpecialistProfile.GetStatusResponse)
    |> Proto.SpecialistProfile.GetStatusResponse.new()
  end
end
