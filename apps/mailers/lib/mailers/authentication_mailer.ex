defmodule Mailers.AuthenticationMailer do
  use Mailers.Partials

  import Mockery.Macro

  @from_name "DrOnline"

  def send_verification_link(specialist_email, specialist_type, verification_token) do
    panel_url = Application.get_env(:web, :specialist_panel_url)

    specialist_type = String.downcase(specialist_type)

    url =
      panel_url
      |> Path.join("verify")
      |> Path.join(specialist_type)
      |> Path.join(verification_token)

    with {:ok, link} <- Firebase.dynamic_link(url, app_name: :specialist) do
      body = %{
        recipients: [%{address: %{email: specialist_email}}],
        content: %{
          from: %{
            name: @from_name,
            email: Application.get_env(:web, :support_email)
          },
          subject: "DrOnline - Email address verification",
          html: verification_html(link, @css),
          text: verification_text(link)
        },
        options: %{inline_css: true}
      }

      mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
    end
  end

  def send_warning_info(specialist_email) do
    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Warning",
        html: warning_html(specialist_email, @css),
        text: warning_text(specialist_email)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_password_recovery_link(specialist_email, password_recovery_token) do
    panel_url = Application.get_env(:web, :specialist_panel_url)
    link = panel_url <> "/password_recovery/" <> password_recovery_token

    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Password recovery",
        html: password_recovery_html(link, @css),
        text: password_recovery_text(link)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_password_change_link(specialist_email, password_change_confirmation_token) do
    panel_url = Application.get_env(:web, :specialist_panel_url)
    link = panel_url <> "/change_password/" <> password_change_confirmation_token

    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Password change",
        html: password_change_html(link, @css),
        text: password_change_text(link)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  path = Path.expand("authentication_mailer/send_password_recovery_link.html.eex", __DIR__)
  EEx.function_from_file(:defp, :password_recovery_html, path, [:link, :css])
  path = Path.expand("authentication_mailer/send_password_recovery_link.text.eex", __DIR__)
  EEx.function_from_file(:defp, :password_recovery_text, path, [:link])

  path = Path.expand("authentication_mailer/send_password_change_link.html.eex", __DIR__)
  EEx.function_from_file(:defp, :password_change_html, path, [:link, :css])
  path = Path.expand("authentication_mailer/send_password_change_link.text.eex", __DIR__)
  EEx.function_from_file(:defp, :password_change_text, path, [:link])

  path = Path.expand("authentication_mailer/send_verification_link.html.eex", __DIR__)
  EEx.function_from_file(:defp, :verification_html, path, [:link, :css])
  path = Path.expand("authentication_mailer/send_verification_link.text.eex", __DIR__)
  EEx.function_from_file(:defp, :verification_text, path, [:link])

  path = Path.expand("authentication_mailer/send_warning.html.eex", __DIR__)
  EEx.function_from_file(:defp, :warning_html, path, [:email, :css])
  path = Path.expand("authentication_mailer/send_warning.text.eex", __DIR__)
  EEx.function_from_file(:defp, :warning_text, path, [:email])
end
