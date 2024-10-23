defmodule Mailers.MedicationsMailer do
  require Logger
  use Mailers.Partials

  import Mockery.Macro

  @from_name "DrOnline"

  def send_pdf_receipt(
        %{
          patient_email: patient_email,
          patient_name: patient_name
        } = attrs
      )
      when not is_nil(patient_email) do
    now_unix_string = DateTime.utc_now() |> DateTime.to_unix() |> to_string()

    {:ok, pdf_data} =
      attrs
      |> Mailers.MedsPaymentReceipt.generate_receipt()
      |> Mailers.PDF.from_html_to_base_64()

    body = %{
      recipients: [%{address: %{email: patient_email}}],
      content: %{
        from: %{
          name: @from_name,
          email: Application.get_env(:web, :support_email)
        },
        subject: "Medication payment receipt",
        # html: medication_payment_receipt_html(@css),
        text: medication_payment_receipt(patient_name),
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

  def send_pdf_receipt(_) do
    Logger.info("Unable to send medication payment receipt PDF email")

    _ =
      Sentry.capture_message(
        "Mailer.MedicationsMailer: failed to send medication payment receipt PDF email",
        level: "error"
      )
  end

  path = Path.expand("medications/medication_payment_receipt.text.eex", __DIR__)
  EEx.function_from_file(:defp, :medication_payment_receipt, path, [:patient_name])
end
