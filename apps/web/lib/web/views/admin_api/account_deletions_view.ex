defmodule Web.AdminApi.AccountDeletionsView do
  use Web, :view

  def render("index.proto", %{
        patient_account_deletions_with_info: patient_account_deletions_with_info,
        specialist_account_deletions_with_info: specialist_account_deletions_with_info
      }) do
    patient_account_deletion_protos =
      render_many(
        patient_account_deletions_with_info,
        __MODULE__,
        "account_deletion.proto",
        as: :patient_account_deletion_with_info
      )

    specialist_account_deletion_protos =
      render_many(
        specialist_account_deletions_with_info,
        __MODULE__,
        "account_deletion.proto",
        as: :specialist_account_deletion_with_info
      )

    account_deletion_protos =
      patient_account_deletion_protos ++ specialist_account_deletion_protos

    %Proto.AdminPanel.GetAccountDeletionsResponse{
      account_deletions: Enum.sort_by(account_deletion_protos, & &1.created_at, :desc)
    }
  end

  def render("account_deletion.proto", %{
        patient_account_deletion_with_info: %{
          account_deletion: account_deletion,
          basic_info: basic_info
        }
      }) do
    %Proto.AdminPanel.AccountDeletion{
      id: account_deletion.id,
      status: Web.ProtoHelpers.map_account_deletion_status(account_deletion.status),
      type: Web.ProtoHelpers.map_account_deletion_type(:PATIENT),
      created_at:
        render_one(
          parse_timestamp(account_deletion.inserted_at),
          Proto.GenericsView,
          "datetime.proto",
          as: :datetime
        ),
      basic_info: {
        :patient_basic_info,
        Web.View.PatientProfile.render_basic_info(basic_info)
      }
    }
  end

  def render("account_deletion.proto", %{
        specialist_account_deletion_with_info: %{
          account_deletion: account_deletion,
          basic_info: basic_info
        }
      }) do
    %Proto.AdminPanel.AccountDeletion{
      id: account_deletion.id,
      status: Web.ProtoHelpers.map_account_deletion_status(account_deletion.status),
      type: Web.ProtoHelpers.map_account_deletion_type(:SPECIALIST),
      created_at:
        render_one(
          parse_timestamp(account_deletion.inserted_at),
          Proto.GenericsView,
          "datetime.proto",
          as: :datetime
        ),
      basic_info: {
        :specialist_basic_info,
        Web.View.SpecialistProfile.render_basic_info(basic_info)
      }
    }
  end

  defp parse_timestamp(nil), do: nil
  defp parse_timestamp(timestamp), do: %{timestamp: Timex.to_unix(timestamp)}
end
