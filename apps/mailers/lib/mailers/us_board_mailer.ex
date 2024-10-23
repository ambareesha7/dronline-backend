defmodule Mailers.UsBoardMailer do
  use Mailers.Partials

  import Mockery.Macro

  @from_name "DrOnline"

  def send_patient_second_opinion(%{
        patient_email: patient_email,
        us_board_request_id: us_board_request_id,
        specialist_name: specialist_name
      }) do
    {:ok, dynamic_link} = generate_dynamic_link(us_board_request_id)

    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Second opinion submitted",
        html: specialist_submitted_second_opinion_html(dynamic_link, specialist_name, @css),
        text: specialist_submitted_second_opinion_text(dynamic_link, specialist_name)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_admin_new_request do
    body = %{
      recipients: [
        %{address: %{email: admin_mail_address()}},
        %{address: %{email: appunite_email_address()}}
      ],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "New US Board Request",
        html: admin_new_request_html(@css),
        text: admin_new_request_text()
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def specialist_assigned_to_request(specialist_email) do
    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "You've been assigned to new US Board request",
        html: specialist_assigned_to_request_html(us_board_dynamic_link(), @css),
        text: specialist_assigned_to_request_text(us_board_dynamic_link())
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def specialist_accepted_request(%{specialist_name: specialist_name}) do
    body = %{
      recipients: [
        %{address: %{email: admin_mail_address()}},
        %{address: %{email: appunite_email_address()}}
      ],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Specialist accepted US Board request",
        html: specialist_accepted_request_html(specialist_name, @css),
        text: specialist_accepted_request_text(specialist_name)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def specialist_rejected_request do
    body = %{
      recipients: [
        %{address: %{email: admin_mail_address()}},
        %{address: %{email: appunite_email_address()}}
      ],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Specialist rejected US Board request",
        html: specialist_rejected_request_html(@css),
        text: specialist_rejected_request_text()
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def patient_scheduled_call(specialist_email) do
    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Patient scheduled a visit for US Board request",
        html: patient_scheduled_call_html(us_board_web_link(), @css),
        text: patient_scheduled_call_text(us_board_web_link())
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def patient_request_confirmation(patient_email, us_board_request_id) do
    {:ok, dynamic_link} = generate_dynamic_link(us_board_request_id)

    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "You've requested a second opinion",
        html: patient_confirmation_html(dynamic_link, @css),
        text: patient_confirmation_text(dynamic_link)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def specialist_set_availability(patient_email) do
    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Specialist set availability",
        html: specialist_set_availability_html(@css),
        text: specialist_set_availability_text()
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  defp admin_mail_address do
    Application.get_env(:mailers, :admin_email)
  end

  # TODO Remove later, added for test
  defp appunite_email_address do
    Application.get_env(:mailers, :appunite_email)
  end

  defp us_board_web_link do
    base_url = Application.get_env(:web, :specialist_panel_url)
    us_board_path = "/us-board-second-opinion"

    base_url
    |> URI.merge(us_board_path)
    |> to_string()
  end

  defp us_board_dynamic_link do
    base_url = Application.get_env(:firebase, :dynamic_link_domain)
    us_board_path = "/us-board-second-opinion"

    "https://#{base_url}"
    |> URI.merge(us_board_path)
    |> to_string()
  end

  defp generate_dynamic_link(us_board_request_id) do
    url =
      :web
      |> Application.get_env(:specialist_panel_url)
      |> Path.join("us-board")
      |> Path.join(us_board_request_id)

    Firebase.dynamic_link(url, app_name: :patient)
  end

  path = Path.expand("us_board_mailer/send_patient_second_opinion.html.eex", __DIR__)

  EEx.function_from_file(
    :defp,
    :specialist_submitted_second_opinion_html,
    path,
    [:dynamic_link, :specialist_name] ++ [:css]
  )

  path = Path.expand("us_board_mailer/send_patient_second_opinion.text.eex", __DIR__)

  EEx.function_from_file(:defp, :specialist_submitted_second_opinion_text, path, [
    :dynamic_link,
    :specialist_name
  ])

  path = Path.expand("us_board_mailer/send_admin_new_request.html.eex", __DIR__)
  EEx.function_from_file(:defp, :admin_new_request_html, path, [] ++ [:css])
  path = Path.expand("us_board_mailer/send_admin_new_request.text.eex", __DIR__)
  EEx.function_from_file(:defp, :admin_new_request_text, path, [])

  path = Path.expand("us_board_mailer/send_assigned_specialist_request.html.eex", __DIR__)
  EEx.function_from_file(:defp, :specialist_assigned_to_request_html, path, [:link] ++ [:css])
  path = Path.expand("us_board_mailer/send_assigned_specialist_request.text.eex", __DIR__)
  EEx.function_from_file(:defp, :specialist_assigned_to_request_text, path, [:link])

  path = Path.expand("us_board_mailer/send_specialist_accepted_request.html.eex", __DIR__)

  EEx.function_from_file(
    :defp,
    :specialist_accepted_request_html,
    path,
    [:specialist_name] ++ [:css]
  )

  path = Path.expand("us_board_mailer/send_specialist_accepted_request.text.eex", __DIR__)
  EEx.function_from_file(:defp, :specialist_accepted_request_text, path, [:specialist_name])

  path = Path.expand("us_board_mailer/send_specialist_rejected_request.html.eex", __DIR__)
  EEx.function_from_file(:defp, :specialist_rejected_request_html, path, [] ++ [:css])
  path = Path.expand("us_board_mailer/send_specialist_rejected_request.text.eex", __DIR__)
  EEx.function_from_file(:defp, :specialist_rejected_request_text, path, [])

  path = Path.expand("us_board_mailer/send_patient_scheduled_call.html.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_scheduled_call_html, path, [:link] ++ [:css])
  path = Path.expand("us_board_mailer/send_patient_scheduled_call.text.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_scheduled_call_text, path, [:link])

  path = Path.expand("us_board_mailer/send_patient_specialist_set_availability.html.eex", __DIR__)
  EEx.function_from_file(:defp, :specialist_set_availability_html, path, [] ++ [:css])
  path = Path.expand("us_board_mailer/send_patient_specialist_set_availability.text.eex", __DIR__)
  EEx.function_from_file(:defp, :specialist_set_availability_text, path, [])

  path = Path.expand("us_board_mailer/send_patient_request_confirmation.html.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_confirmation_html, path, [:dynamic_link] ++ [:css])
  path = Path.expand("us_board_mailer/send_patient_request_confirmation.text.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_confirmation_text, path, [:dynamic_link])
end
