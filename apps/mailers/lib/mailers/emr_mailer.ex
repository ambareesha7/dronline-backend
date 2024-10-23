defmodule Mailers.EMRMailer do
  use Mailers.Partials

  import Mockery.Macro

  @from_name "DrOnline"

  def send_patient_invitation(patient_email, specialist_data, dynamic_link) do
    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Invitation",
        html: patient_invitation_html(specialist_data, dynamic_link, @css),
        text: patient_invitation_text(specialist_data, dynamic_link)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_patient_assigned_meds(patient_email, specialist_name, dynamic_link) do
    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Medications assigned",
        # html: patient_invitation_html(specialist_data, dynamic_link, @css),
        text:
          "Dr. #{specialist_name} " <>
            "has assigned you medications please click on the link #{dynamic_link} to order the medicine"
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_patient_invited(specialist_email, invitation) do
    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Your invitation has been sent",
        html: patient_invitated_html(invitation, @css),
        text: patient_invitated_text(invitation)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  def send_patient_accepted_invitation(specialist_email, patient_data) do
    body = %{
      recipients: [%{address: %{email: specialist_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Your invitation has been accepted",
        html: patient_accepted_invitation_html(patient_data, @css),
        text: patient_accepted_invitation_text(patient_data)
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  vars = [:specialist_data, :dynamic_link]
  path = Path.expand("emr_mailer/send_patient_invitation.html.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_invitation_html, path, vars ++ [:css])
  path = Path.expand("emr_mailer/send_patient_invitation.text.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_invitation_text, path, vars)

  path = Path.expand("emr_mailer/send_patient_invited.html.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_invitated_html, path, [:invitation, :css])
  path = Path.expand("emr_mailer/send_patient_invited.text.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_invitated_text, path, [:invitation])
  path = Path.expand("emr_mailer/send_patient_medication.text.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_medication, path, vars)

  path = Path.expand("emr_mailer/send_patient_accepted_invitation.html.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_accepted_invitation_html, path, [:patient_data, :css])
  path = Path.expand("emr_mailer/send_patient_accepted_invitation.text.eex", __DIR__)
  EEx.function_from_file(:defp, :patient_accepted_invitation_text, path, [:patient_data])
end
