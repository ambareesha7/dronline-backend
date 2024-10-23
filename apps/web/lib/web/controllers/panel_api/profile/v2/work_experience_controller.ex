defmodule Web.PanelApi.Profile.V2.WorkExperienceController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    bio = SpecialistProfile.get_bio(specialist_id)

    conn
    |> render("show.proto", %{work_experience: bio})
  end

  @decode Proto.SpecialistProfileV2.UpdateWorkExperienceRequestV2
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    work_experience = Enum.map(conn.assigns.protobuf.work_experience, &Map.from_struct/1)

    with {:ok, bio} <-
           SpecialistProfile.update_bio(specialist_id, %{work_experience: work_experience}) do
      conn
      |> render("update.proto", %{work_experience: bio})
    end
  end
end

defmodule Web.PanelApi.Profile.V2.WorkExperienceView do
  use Web, :view

  def render("show.proto", %{work_experience: work_experience}) do
    %Proto.SpecialistProfileV2.GetWorkExperienceV2{
      work_experience: Web.View.SpecialistProfileV2.render_work_experience(work_experience)
    }
  end

  def render("update.proto", %{work_experience: work_experience}) do
    %Proto.SpecialistProfileV2.UpdateWorkExperienceResponseV2{
      work_experience: Web.View.SpecialistProfileV2.render_work_experience(work_experience)
    }
  end
end
