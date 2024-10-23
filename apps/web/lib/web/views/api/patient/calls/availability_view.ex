defmodule Web.Api.Calls.AvailabilityView do
  use Web, :view

  def render("local_clinic.proto", %{clinic: nil}) do
    %{
      clinic: nil
    }
    |> Proto.validate!(Proto.Calls.LocalClinicResponse)
    |> Proto.Calls.LocalClinicResponse.new()
  end

  def render("local_clinic.proto", %{clinic: clinic}) do
    %{
      clinic:
        {:local_clinic,
         %Proto.Calls.Clinic{
           name: clinic.name,
           logo_url: clinic.logo_url
         }}
    }
    |> Proto.validate!(Proto.Calls.LocalClinicResponse)
    |> Proto.Calls.LocalClinicResponse.new()
  end
end
