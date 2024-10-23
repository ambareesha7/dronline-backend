defmodule Web.AdminApi.ExternalSpecialistsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    {:ok, external_specialists, next_token} = Admin.fetch_external_specialists(params)

    render(conn, "index.proto", %{
      external_specialists: external_specialists,
      next_token: next_token
    })
  end

  def show(conn, params) do
    specialist_id = params["id"]

    with {:ok, external_specialist} <- Admin.fetch_external_specialist(specialist_id) do
      render(conn, "show.proto", %{external_specialist: external_specialist})
    end
  end
end

defmodule Web.AdminApi.ExternalSpecialistsView do
  use Web, :view

  def render("index.proto", %{external_specialists: external_specialists, next_token: next_token}) do
    %Proto.AdminPanel.GetExternalSpecialistsResponse{
      external_specialists:
        render_many(external_specialists, Proto.AdminPanelView, "external_specialist.proto",
          as: :external_specialist
        ),
      next_token: next_token
    }
  end

  def render("show.proto", %{external_specialist: external_specialist}) do
    %Proto.AdminPanel.GetExternalSpecialistResponse{
      joined_at: parse_timestamp(external_specialist.inserted_at),
      approval_status_updated_at: parse_timestamp(external_specialist.approval_status_updated_at),
      approval_status:
        external_specialist.approval_status
        |> String.to_existing_atom()
        |> Proto.enum(Proto.AdminPanel.GetExternalSpecialistResponse.ApprovalStatus)
    }
  end

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(timestamp),
    do: %Proto.Generics.DateTime{
      timestamp: Timex.to_unix(timestamp)
    }
end
