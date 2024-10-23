defmodule Web.View.PatientProfile do
  alias PatientProfile.Schema, as: Patient

  alias PatientProfile.Address
  alias PatientProfile.BasicInfo
  alias PatientProfile.BMI
  alias PatientProfile.ReviewOfSystem

  def render_basic_info(%BasicInfo{} = basic_info, %Patient{} = patient) do
    %Proto.PatientProfile.BasicInfo{
      title: basic_info.title |> parse_title(),
      gender: basic_info.gender |> parse_gender(),
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      birth_date: basic_info.birth_date |> Web.View.Generics.render_datetime(),
      email: basic_info.email,
      join_date: patient.inserted_at |> Timex.to_unix(),
      avatar_url: Upload.signed_download_url(basic_info.avatar_resource_path),
      is_insured: basic_info.is_insured
    }
  end

  def render_basic_info(%BasicInfo{} = basic_info) do
    %Proto.PatientProfile.BasicInfo{
      title: basic_info.title |> parse_title(),
      gender: basic_info.gender |> parse_gender(),
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      birth_date: basic_info.birth_date |> Web.View.Generics.render_datetime(),
      email: basic_info.email,
      avatar_url: Upload.signed_download_url(basic_info.avatar_resource_path),
      is_insured: basic_info.is_insured
    }
  end

  def render_address(nil) do
    Proto.PatientProfile.Address.new()
  end

  def render_address(%Address{} = address) do
    %Proto.PatientProfile.Address{
      street: address.street,
      home_number: address.home_number,
      zip_code: address.zip_code,
      city: address.city,
      country: address.country,
      additional_numbers: address.additional_numbers,
      neighborhood: address.neighborhood
    }
  end

  def render_bmi(%BMI{} = bmi) do
    %Proto.PatientProfile.BMI{
      height: bmi.height |> Web.View.Generics.render_height(),
      weight: bmi.weight |> Web.View.Generics.render_weight()
    }
  end

  def render_child_profile(%BasicInfo{} = basic_info, %Patient{} = patient, auth_token) do
    %Proto.PatientProfile.ChildProfile{
      basic_info: render_basic_info(basic_info, patient),
      auth_token: auth_token,
      patient_id: patient.id
    }
  end

  def render_review_of_system(%ReviewOfSystem{} = review_of_system) do
    %Proto.PatientProfile.ReviewOfSystem{
      form: review_of_system.form,
      inserted_at: review_of_system.inserted_at |> Timex.to_unix(),
      provided_by_specialist_id: review_of_system.provided_by_specialist_id
    }
  end

  defp parse_title(nil), do: nil

  defp parse_title(title) do
    title |> String.to_existing_atom() |> Proto.Generics.Title.value()
  end

  defp parse_gender(nil), do: nil

  defp parse_gender(gender) do
    gender |> String.to_existing_atom() |> Proto.Generics.Gender.value()
  end
end
