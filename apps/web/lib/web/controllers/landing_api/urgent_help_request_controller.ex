defmodule Web.LandingApi.UrgentHelpRequestController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.Visits.LandingUrgentHelpRequest
  def request_urgent_help(conn, _params) do
    proto = conn.assigns.protobuf

    account_params = %{
      phone_number: proto.phone_number,
      email: proto.email,
      first_name: proto.first_name,
      last_name: proto.last_name
    }

    with {:ok,
          %{
            patient_account: %Authentication.Patient.Account{} = patient_account,
            auth_token: auth_token
          }} <-
           Authentication.create_patient_account_without_signup(account_params),
         {:ok,
          %{
            urgent_care_request_id: urgent_care_request_id,
            payment_url: payment_url
          }} <-
           UrgentCare.Initialize.call(%{
             patient: %{
               patient_email: proto.email,
               patient_id: patient_account.main_patient_id,
               first_name: proto.first_name,
               last_name: proto.last_name
             },
             host: conn.host
           }) do
      render(conn, "request_urgent_help.proto", %{
        patient_id: patient_account.main_patient_id,
        urgent_help_request_id: urgent_care_request_id,
        payment_url: payment_url,
        auth_token: auth_token
      })
    end
  end
end

defmodule Web.LandingApi.UrgentHelpRequestView do
  use Web, :view

  def render("request_urgent_help.proto", %{
        patient_id: patient_id,
        urgent_help_request_id: urgent_help_request_id,
        payment_url: payment_url,
        auth_token: auth_token
      }) do
    %Proto.Visits.LandingUrgentHelpResponse{
      patient_id: patient_id,
      urgent_help_request_id: urgent_help_request_id,
      payment_url: payment_url,
      auth_token: auth_token
    }
  end
end
