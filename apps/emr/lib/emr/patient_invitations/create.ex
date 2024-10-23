defmodule EMR.PatientInvitations.Create do
  import Mockery.Macro

  alias EMR.PatientInvitations.PatientInvitation
  alias EMR.SpecialistData

  def call(specialist_id, invitation_proto) do
    {:ok, specialist_data} = SpecialistData.fetch_by_id(specialist_id)

    case Authentication.get_patient_account_by_phone_number(invitation_proto.phone_number) do
      nil ->
        send_invitation(specialist_data, invitation_proto)

      _account ->
        handle_existing_patient()
    end
  end

  defp send_invitation(specialist_data, invitation_proto) do
    specialist_id = specialist_data.specialist_id

    create_params = %{phone_number: invitation_proto.phone_number, email: invitation_proto.email}

    with {:ok, _invitation} <- PatientInvitation.create(specialist_id, create_params),
         {:ok, dynamic_link} <- Firebase.dynamic_link("patient", app_name: :patient),
         :ok <- send_sms(invitation_proto, dynamic_link, specialist_data) do
      {:ok, _job} = send_patient_email(invitation_proto, dynamic_link, specialist_data)
      {:ok, _job} = send_specialist_email(invitation_proto, specialist_data)
    end
  end

  defp handle_existing_patient do
    {:error, "this patient is already registered"}
  end

  defp send_patient_email(%{email: nil}, _dynamic_link, _specialist_data) do
    {:ok, nil}
  end

  defp send_patient_email(invitation_proto, dynamic_link, specialist_data) do
    %{
      type: "PATIENT_INVITATION",
      dynamic_link: dynamic_link,
      patient_email: invitation_proto.email,
      specialist_data: specialist_data
    }
    |> Mailers.MailerJobs.new()
    |> Oban.insert()
  end

  defp send_specialist_email(invitation_proto, specialist_data) do
    %{
      type: "PATIENT_INVITED",
      specialist_email: specialist_data.specialist.email,
      invitation: invitation_proto
    }
    |> Mailers.MailerJobs.new()
    |> Oban.insert()
  end

  defp send_sms(%{phone_number: ""}, _, _), do: :ok
  defp send_sms(%{phone_number: nil}, _, _), do: :ok

  defp send_sms(invitation_proto, dynamic_link, specialist_data) do
    body =
      "Dr. #{specialist_data.last_name} invites you " <>
        "to signup and join him on DrOnline " <>
        "to schedule your visit. #{dynamic_link}"

    resp =
      mockable(Twilio.SMSClient, by: Twilio.SMSClientMock).send(
        invitation_proto.phone_number,
        body
      )

    case resp do
      :ok ->
        :ok

      {:error, {:ok, %Tesla.Env{body: %{"message" => message}}}} ->
        {:error, message}
    end
  end
end
