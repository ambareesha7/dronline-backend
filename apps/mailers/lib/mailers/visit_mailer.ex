defmodule Mailers.VisitMailer do
  use Mailers.Partials

  import Mockery.Macro

  @from_name "DrOnline"

  def send_visit_confirmation(%{
        patient_email: patient_email,
        amount: amount,
        currency: currency,
        visit_date: visit_date,
        payment_date: payment_date,
        specialist_name: specialist_name,
        medical_category_name: medical_category_name
      }) do
    now_unix_string = DateTime.utc_now() |> DateTime.to_unix() |> to_string()

    {:ok, pdf_data} =
      %{
        amount: amount,
        currency: currency,
        visit_date: visit_date,
        payment_date: payment_date,
        specialist_name: specialist_name,
        medical_category_name: medical_category_name
      }
      |> recipe_for_payment(@css)
      |> Mailers.PDF.from_html_to_base_64()

    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Visit confirmation",
        html: visit_confirmation_html(@css),
        text: visit_confirmation_text(),
        attachments: [
          %{
            name: now_unix_string <> ".pdf",
            type: "application/pdf",
            data: pdf_data
          }
        ]
      },
      options: %{inline_css: true}
    }

    mockable(Mailers.Sparkpost, by: Mailers.SparkpostMock).send(body)
  end

  path = Path.expand("visit_mailer/send_patient_visit_confirmation.html.eex", __DIR__)
  EEx.function_from_file(:defp, :visit_confirmation_html, path, [] ++ [:css])
  path = Path.expand("visit_mailer/send_patient_visit_confirmation.text.eex", __DIR__)
  EEx.function_from_file(:defp, :visit_confirmation_text, path, [])
  path = Path.expand("visit_mailer/recipe_for_payment.html.eex", __DIR__)
  EEx.function_from_file(:defp, :recipe_for_payment, path, [:pdf_data] ++ [:css])
end
