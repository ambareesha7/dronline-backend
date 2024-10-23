defmodule Web.AdminApi.InternalSpecialistsView do
  use Web, :view

  def render("create.proto", %{internal_specialist: internal_specialist}) do
    %{
      internal_specialist_account:
        render_one(
          internal_specialist,
          Proto.AdminPanelView,
          "internal_specialist_account.proto",
          as: :internal_specialist
        )
    }
    |> Proto.validate!(Proto.AdminPanel.CreateInternalSpecialistResponse)
    |> Proto.AdminPanel.CreateInternalSpecialistResponse.new()
  end

  def render("index.proto", %{internal_specialists: internal_specialists, next_token: next_token}) do
    %{
      internal_specialists:
        render_many(internal_specialists, Proto.AdminPanelView, "internal_specialist.proto",
          as: :internal_specialist
        ),
      next_token: next_token
    }
    |> Proto.validate!(Proto.AdminPanel.GetInternalSpecialistsResponse)
    |> Proto.AdminPanel.GetInternalSpecialistsResponse.new()
  end

  def render("show.proto", %{internal_specialist: internal_specialist}) do
    %{
      completed_at:
        render_one(internal_specialist.completed_at, Proto.GenericsView, "datetime.proto",
          as: :datetime
        ),
      created_at:
        render_one(internal_specialist.created_at, Proto.GenericsView, "datetime.proto",
          as: :datetime
        ),
      type:
        internal_specialist.type
        |> Proto.AdminPanel.GetInternalSpecialistResponse.Type.value()
    }
    |> Proto.validate!(Proto.AdminPanel.GetInternalSpecialistResponse)
    |> Proto.AdminPanel.GetInternalSpecialistResponse.new()
  end
end
