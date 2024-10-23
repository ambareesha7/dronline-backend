defmodule Mailers.AdminMailer do
  use Mailers.Partials

  import Mockery.Macro

  @from_name "DrOnline"

  def send_account_creation_message(specialist_email, password_recovery_token) do
    panel_url = Application.get_env(:web, :specialist_panel_url)
    link = panel_url <> "/password_recovery/" <> password_recovery_token

    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Account has been created",
        html: account_creation_html(link, @css),
        text: account_creation_text(link)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_account_creation_by_team_admin_message(specialist_email, password_recovery_token) do
    panel_url = Application.get_env(:web, :specialist_panel_url)
    link = panel_url <> "/password_recovery/" <> password_recovery_token

    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "You've been invited to join a team in DrOnline",
        html: account_creation_by_team_admin_html(link, @css),
        text: account_creation_by_team_admin_text(link)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_account_approval_message(specialist_email) do
    url =
      :web
      |> Application.get_env(:specialist_panel_url)
      |> Path.join("membership")

    with {:ok, link} <- Firebase.dynamic_link(url, app_name: :specialist) do
      body = %{
        recipients: [%{address: %{email: specialist_email}}],
        content: %{
          from: %{
            name: @from_name,
            email: Application.get_env(:web, :support_email)
          },
          subject: "Account has been approved",
          html: account_approval_html(link, @css),
          text: account_approval_text(link)
        },
        options: %{inline_css: true}
      }

      mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
    end
  end

  def send_account_rejection_message(specialist_email) do
    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Account has been rejected",
        html: account_rejection_html(@css),
        text: account_rejection_text()
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  path = Path.expand("admin_mailer/send_account_creation_message.html.eex", __DIR__)
  EEx.function_from_file(:defp, :account_creation_html, path, [:link, :css])
  path = Path.expand("admin_mailer/send_account_creation_message.text.eex", __DIR__)
  EEx.function_from_file(:defp, :account_creation_text, path, [:link])

  path = Path.expand("admin_mailer/send_account_creation_by_team_admin_message.html.eex", __DIR__)
  EEx.function_from_file(:defp, :account_creation_by_team_admin_html, path, [:link, :css])
  path = Path.expand("admin_mailer/send_account_creation_by_team_admin_message.text.eex", __DIR__)
  EEx.function_from_file(:defp, :account_creation_by_team_admin_text, path, [:link])

  path = Path.expand("admin_mailer/send_account_approval_message.html.eex", __DIR__)
  EEx.function_from_file(:defp, :account_approval_html, path, [:link, :css])
  path = Path.expand("admin_mailer/send_account_approval_message.text.eex", __DIR__)
  EEx.function_from_file(:defp, :account_approval_text, path, [:link])

  path = Path.expand("admin_mailer/send_account_rejection_message.html.eex", __DIR__)
  EEx.function_from_file(:defp, :account_rejection_html, path, [:css])
  path = Path.expand("admin_mailer/send_account_rejection_message.text.eex", __DIR__)
  EEx.function_from_file(:defp, :account_rejection_text, path, [])
end
