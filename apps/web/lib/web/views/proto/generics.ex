defmodule Web.View.Generics do
  defguardp is_datetime(datetime) when :erlang.map_get(:__struct__, datetime) == DateTime

  def render_specialist(%Web.SpecialistGenericData{} = data) do
    %{
      specialist: specialist,
      basic_info: basic_info,
      deprecated: deprecated,
      medical_categories: medical_categories,
      medical_credential: medical_credential
    } = data

    %Proto.Generics.Specialist{
      id: specialist.id,
      title: basic_info.title |> parse_title(),
      gender: basic_info.gender |> parse_gender(),
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      avatar_url: basic_info.image_url,
      type: specialist.type |> specialist_type(),
      package: specialist.package_type |> specialist_package(),
      deprecated: deprecated,
      medical_title: basic_info.medical_title |> parse_medical_title(),
      medical_categories:
        Enum.map(medical_categories, &Proto.Generics.Specialist.MedicalCategory.new/1),
      dha_license: medical_credential.dea_number_url
    }
  end

  def render_patient(%Web.PatientGenericData{} = data) do
    basic_info = data.basic_info

    %Proto.Generics.Patient{
      id: basic_info.patient_id,
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      title: basic_info.title |> parse_title(),
      gender: basic_info.gender |> parse_gender(),
      birth_date: basic_info.birth_date |> render_datetime(),
      avatar_url: Upload.signed_download_url(basic_info.avatar_resource_path),
      related_adult: parse_related_adult(data.related_adult_patient_id),
      is_insured: basic_info.is_insured,
      insurance_provider_name: basic_info.insurance_provider_name,
      insurance_member_id: basic_info.insurance_member_id
    }
  end

  def parse_related_adult(nil) do
    nil
  end

  def parse_related_adult(patient_id) when is_integer(patient_id) do
    %Proto.Generics.Patient.RelatedAdult{id: patient_id}
  end

  def render_datetime(nil) do
    nil
  end

  def render_datetime(datetime) when is_datetime(datetime) do
    %Proto.Generics.DateTime{
      timestamp: DateTime.to_unix(datetime)
    }
  end

  def render_datetime(%{timestamp: timestamp}) when is_integer(timestamp) do
    %Proto.Generics.DateTime{
      timestamp: timestamp
    }
  end

  def render_datetime(datetime) do
    %Proto.Generics.DateTime{
      timestamp: Timex.to_unix(datetime)
    }
  end

  def render_coordinates(nil), do: nil

  def render_coordinates(coordinates) do
    %Proto.Generics.Coordinates{
      lat: coordinates.lat,
      lon: coordinates.lon
    }
  end

  def render_height(nil), do: nil

  def render_height(height) do
    %Proto.Generics.Height{
      value: height
    }
  end

  def render_weight(nil), do: nil

  def render_weight(weight) do
    %Proto.Generics.Weight{
      value: weight
    }
  end

  def specialist_type(type) when is_binary(type) do
    type |> String.to_existing_atom() |> Proto.Generics.Specialist.Type.value()
  end

  def specialist_package(package_type) when is_binary(package_type) do
    package_type |> String.to_existing_atom() |> Proto.Generics.Specialist.Package.value()
  end

  def parse_gender(gender) when is_binary(gender) do
    gender |> String.to_existing_atom() |> Proto.Generics.Gender.value()
  end

  def parse_gender(nil) do
    nil
  end

  defp parse_title(nil) do
    Proto.Generics.Title.value(:UNKNOWN_TITLE)
  end

  defp parse_title(title) when is_binary(title) do
    title |> String.to_existing_atom() |> Proto.Generics.Title.value()
  end

  def parse_medical_title(medical_title) when is_binary(medical_title) do
    medical_title |> String.to_existing_atom() |> Proto.Generics.MedicalTitle.value()
  end
end
