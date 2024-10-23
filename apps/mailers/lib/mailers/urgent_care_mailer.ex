defmodule Mailers.UrgentCareMailer do
  use Mailers.Partials

  import Mockery.Macro

  @from_name "DrOnline"

  def send_patient_urgent_care_summary(%{
        summary_pdf: summary_pdf,
        patient_email: patient_email,
        amount: amount,
        currency: currency,
        visit_date: visit_date,
        payment_date: payment_date,
        specialist_name: specialist_name
      }) do
    now_unix_string = DateTime.utc_now() |> DateTime.to_unix() |> to_string()

    {:ok, recipe_pdf_data} =
      %{
        amount: amount,
        currency: currency,
        visit_date: visit_date,
        payment_date: payment_date,
        specialist_name: specialist_name
      }
      |> urgent_care_recipe(@css)
      |> Mailers.PDF.from_html_to_base_64()

    attachments = [
      %{
        name: now_unix_string <> "_summary.pdf",
        type: "application/pdf",
        data: summary_pdf
      },
      %{
        name: now_unix_string <> "_recipe.pdf",
        type: "application/pdf",
        data: recipe_pdf_data
      }
    ]

    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Urgent Care Summary & Recipe",
        html: urgent_care_summary_html(@css)
      },
      attachments: attachments,
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  path = Path.expand("urgent_care_mailer/send_patient_summary.html.eex", __DIR__)
  EEx.function_from_file(:defp, :urgent_care_summary_html, path, [] ++ [:css])
  path = Path.expand("urgent_care_mailer/urgent_care_recipe.html.eex", __DIR__)
  EEx.function_from_file(:defp, :urgent_care_recipe, path, [:pdf_data] ++ [:css])
end
