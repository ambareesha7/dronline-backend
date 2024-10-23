defmodule Web.View.SpecialistProfile do
  alias SpecialistProfile.BasicInfo
  alias SpecialistProfile.Bio
  alias SpecialistProfile.Location

  def render_basic_info(%BasicInfo{} = basic_info) do
    %Proto.SpecialistProfile.BasicInfo{
      title: basic_info.title |> parse_title(),
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      birth_date: basic_info.birth_date |> Web.View.Generics.render_datetime(),
      image_url: basic_info.image_url,
      phone_number: basic_info.phone_number,
      gender: basic_info.gender |> parse_gender(),
      medical_title: basic_info.medical_title |> parse_medical_title()
    }
  end

  def render_bio(nil) do
    Proto.SpecialistProfile.Bio.new()
  end

  def render_bio(%Bio{} = bio) do
    %Proto.SpecialistProfile.Bio{
      description: bio.description,
      education: Enum.map(bio.education, &parse_education_entry/1),
      work_experience: Enum.map(bio.work_experience, &parse_work_experience/1)
    }
  end

  def render_location(%Location{} = location) do
    %Proto.SpecialistProfile.Location{
      street: location.street,
      number: location.number,
      postal_code: location.postal_code,
      city: location.city,
      country: location.country,
      additional_numbers: location.additional_numbers,
      neighborhood: location.neighborhood,
      formatted_address: location.formatted_address,
      coordinates: render_geo_point(location.coordinates)
    }
  end

  def render_specialist(data) do
    %{
      specialist_generic_data: specialist_generic_data,
      location: location
    } = data

    %Proto.SpecialistProfile.DetailedSpecialist{
      specialist: Web.View.Generics.render_specialist(specialist_generic_data),
      country: location.country
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

  defp parse_medical_title(medical_title) do
    medical_title |> String.to_existing_atom() |> Proto.Generics.MedicalTitle.value()
  end

  defp parse_education_entry(education_entry) do
    %Proto.SpecialistProfile.EducationEntry{
      school: education_entry.school,
      field_of_study: education_entry.field_of_study,
      degree: education_entry.degree,
      start_year: education_entry.start_year,
      end_year: education_entry.end_year
    }
  end

  defp parse_work_experience(work_experience) do
    %Proto.SpecialistProfile.WorkExperienceEntry{
      institution: work_experience.institution,
      position: work_experience.position,
      start_year: work_experience.start_year,
      end_year: work_experience.end_year
    }
  end

  defp render_geo_point(nil), do: nil

  defp render_geo_point(%Geo.Point{coordinates: {lat, lon}}) do
    %{
      lat: lat,
      lon: lon
    }
    |> Proto.validate!(Proto.Generics.Coordinates)
    |> Proto.Generics.Coordinates.new()
  end
end
