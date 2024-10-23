defmodule EMR.PatientRecords.RecordPDF do
  @spec generate_for_patient(pos_integer, String.t()) :: {:ok, binary}
  def generate_for_patient(record_id, token) do
    url = "/patient/records/#{record_id}?auth_token=#{token}"

    generate(url)
  end

  @spec generate_for_specialist(pos_integer, pos_integer, String.t()) :: {:ok, binary}
  def generate_for_specialist(patient_id, record_id, token) do
    url = "/patients/#{patient_id}/records/#{record_id}?auth_token=#{token}"

    generate(url)
  end

  defp generate(url) do
    case Tesla.get(client(), url) do
      {:ok, %{status: 200, body: pdf_body}} when pdf_body != "" ->
        {:ok, pdf_body}

      result ->
        _ = Sentry.Context.set_extra_context(%{result: result})
        raise "PDF generation failure"
    end
  end

  defp client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, Application.get_env(:emr, :pdf_service_url)}
    ])
  end
end
