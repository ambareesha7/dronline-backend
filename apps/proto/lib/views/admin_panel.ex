defmodule Proto.AdminPanelView do
  use Proto.View

  def render("external_specialist.proto", %{external_specialist: external_specialist}) do
    %{
      id: external_specialist.id,
      first_name: external_specialist.basic_info.first_name,
      last_name: external_specialist.basic_info.last_name,
      email: external_specialist.email,
      medical_categories:
        render_many(
          external_specialist.medical_categories,
          Proto.MedicalCategoriesView,
          "medical_category_base.proto",
          as: :medical_category
        ),
      approval_status:
        external_specialist.approval_status
        |> String.to_existing_atom()
        |> Proto.enum(Proto.AdminPanel.ExternalSpecialist.ApprovalStatus),
      joined_at:
        render_one(
          parse_timestamp(external_specialist.inserted_at),
          Proto.GenericsView,
          "datetime.proto",
          as: :datetime
        ),
      approval_status_updated_at:
        render_one(
          parse_timestamp(external_specialist.approval_status_updated_at),
          Proto.GenericsView,
          "datetime.proto",
          as: :datetime
        )
    }
    |> Proto.validate!(Proto.AdminPanel.ExternalSpecialist)
    |> Proto.AdminPanel.ExternalSpecialist.new()
  end

  def render("internal_specialist_account.proto", %{internal_specialist: internal_specialist}) do
    %{
      email: internal_specialist.email,
      type:
        internal_specialist.type |> Proto.enum(Proto.AdminPanel.InternalSpecialistAccount.Type)
    }
    |> Proto.validate!(Proto.AdminPanel.InternalSpecialistAccount)
    |> Proto.AdminPanel.InternalSpecialistAccount.new()
  end

  def render("internal_specialist.proto", %{internal_specialist: internal_specialist}) do
    %{
      id: internal_specialist.id,
      first_name: internal_specialist.first_name,
      last_name: internal_specialist.last_name,
      email: internal_specialist.email,
      title: internal_specialist.title |> Proto.enum(Proto.Generics.Title),
      type: internal_specialist.type |> Proto.enum(Proto.AdminPanel.InternalSpecialist.Type),
      status:
        internal_specialist.status |> Proto.enum(Proto.AdminPanel.InternalSpecialist.Status),
      created_at:
        render_one(internal_specialist.created_at, Proto.GenericsView, "datetime.proto",
          as: :datetime
        ),
      completed_at:
        render_one(internal_specialist.completed_at, Proto.GenericsView, "datetime.proto",
          as: :datetime
        )
    }
    |> Proto.validate!(Proto.AdminPanel.InternalSpecialist)
    |> Proto.AdminPanel.InternalSpecialist.new()
  end

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(timestamp),
    do: %Proto.Generics.DateTime{
      timestamp: Timex.to_unix(timestamp)
    }
end
