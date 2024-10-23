defmodule Web.View.SpecialistProfileV2 do
  alias SpecialistProfile.BasicInfo
  alias SpecialistProfile.Bio
  alias SpecialistProfile.Location

  def render_basic_info(nil, nil), do: Proto.SpecialistProfileV2.BasicInfoV2.new()

  def render_basic_info(%BasicInfo{} = basic_info, %Location{} = location) do
    %Proto.SpecialistProfileV2.BasicInfoV2{
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      gender: basic_info.gender |> parse_gender(),
      birth_date: basic_info.birth_date |> Web.View.Generics.render_datetime(),
      profile_image_url: basic_info.image_url,
      medical_title: basic_info.medical_title |> parse_medical_title(),
      phone_number: basic_info.phone_number,
      address: render_address(location)
    }
  end

  def render_address(nil), do: nil

  def render_address(%Location{} = address) do
    %Proto.SpecialistProfileV2.AddressV2{
      street: address.street,
      number: address.number,
      postal_code: address.postal_code,
      city: address.city,
      country: address.country,
      neighborhood: address.neighborhood,
      formatted_address: address.formatted_address,
      coordinates: address.coordinates |> render_geo_point()
    }
  end

  def render_description(nil) do
    Proto.SpecialistProfileV2.ProfileDescriptionV2.new()
  end

  def render_description(%Bio{description: description}) do
    %Proto.SpecialistProfileV2.ProfileDescriptionV2{
      description: description
    }
  end

  def render_education(nil), do: []

  def render_education(%Bio{education: education}) do
    education
    |> Enum.map(fn education_entry ->
      %Proto.SpecialistProfileV2.EducationEntryV2{
        school: education_entry.school,
        field_of_study: education_entry.field_of_study,
        degree: education_entry.degree,
        start_year: education_entry.start_year,
        end_year: education_entry.end_year
      }
    end)
  end

  def render_work_experience(nil), do: []

  def render_work_experience(%Bio{work_experience: work_experience}) do
    work_experience
    |> Enum.map(fn work_experience_entry ->
      %Proto.SpecialistProfileV2.WorkExperienceEntryV2{
        institution: work_experience_entry.institution,
        position: work_experience_entry.position,
        start_year: work_experience_entry.start_year,
        end_year: work_experience_entry.end_year
      }
    end)
  end

  def render_medical_info(medical_credentials, medical_categories) do
    %Proto.SpecialistProfileV2.MedicalInfoV2{
      medical_credentials: render_medical_credentials(medical_credentials),
      medical_categories: render_medical_categories(medical_categories)
    }
  end

  def render_insurance_providers(nil), do: []

  def render_insurance_providers(insurance_providers) do
    insurance_providers
    |> Enum.map(fn insurance_provider ->
      %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
        id: insurance_provider.id,
        name: insurance_provider.name,
        country_id: insurance_provider.country_id
      }
    end)
  end

  def render_insurance_matching_provider(provider) do
    %Proto.SpecialistProfileV2.MatchingInsuranceProviderV2{
      id: provider.id,
      name: provider.name
    }
  end

  def render_search_specialist(data) do
    %{
      specialist_generic_data: %{
        specialist: specialist,
        basic_info: basic_info,
        medical_categories: medical_categories
      },
      location: location,
      prices: prices,
      day_schedules: day_schedules,
      insurance_providers: insurance_providers
    } = data

    %Proto.SpecialistProfileV2.SearchSpecialist{
      id: specialist.id,
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      avatar_url: basic_info.image_url,
      type: Web.View.Generics.specialist_type(specialist.type),
      package: Web.View.Generics.specialist_package(specialist.package_type),
      medical_categories:
        Enum.map(medical_categories, &Proto.Generics.Specialist.MedicalCategory.new/1),
      medical_title: Web.View.Generics.parse_medical_title(basic_info.medical_title),
      location: render_address(location),
      categories_prices: render_categories_prices(prices),
      day_schedules: render_day_schedules(day_schedules),
      insurance_providers: render_insurance_providers(insurance_providers)
    }
  end

  def render_detailed_specialist(data) do
    %{
      specialist_generic_data: specialist_generic_data,
      prices: prices,
      timeslots: timeslots,
      insurance_providers: insurance_providers,
      matching_provider: matching_provider
    } = data

    %Proto.SpecialistProfileV2.DetailedSpecialist{
      specialist_generic_data: Web.View.Generics.render_specialist(specialist_generic_data),
      prices: render_categories_prices(prices),
      timeslots: render_timeslots(timeslots),
      insurance_providers: render_insurance_providers(insurance_providers),
      matching_provider: render_insurance_matching_provider(matching_provider)
    }
  end

  def render_admin_panel_us_board_specialist(specialist) do
    %Proto.AdminPanel.USBoardSpecialist{
      first_name: specialist.first_name,
      last_name: specialist.last_name,
      image_url: specialist.image_url,
      phone_number: specialist.phone_number,
      medical_title: parse_medical_title(specialist.medical_title),
      specialist_id: specialist.specialist_id
    }
  end

  defp render_categories_prices(nil), do: []

  defp render_categories_prices(prices) when is_list(prices) do
    Enum.map(prices, &render_categories_prices/1)
  end

  defp render_categories_prices(%SpecialistProfile.Prices{} = prices) do
    %Proto.SpecialistProfile.CategoryPricesResponse{
      price_minutes_15: prices.price_minutes_15,
      price_minutes_30: prices.price_minutes_30,
      price_minutes_45: prices.price_minutes_45,
      price_minutes_60: prices.price_minutes_60,
      price_second_opinion: prices.price_second_opinion,
      price_in_office: prices.price_in_office,
      prices_enabled: prices.prices_enabled,
      currency: prices.currency,
      currency_in_office: prices.currency_in_office,
      medical_category_id: prices.medical_category_id,
      medical_category_name: prices.medical_category.name,
      medical_category_image_url: prices.medical_category.image_url
    }
  end

  defp render_day_schedules(nil), do: []

  defp render_day_schedules(day_schedules) when is_list(day_schedules) do
    Enum.map(
      day_schedules,
      &Web.View.Visits.render_day_schedule/1
    )
  end

  defp render_timeslots(nil), do: []

  defp render_timeslots(timeslots) when is_list(timeslots) do
    Enum.map(
      timeslots,
      &Web.View.Visits.render_timeslot/1
    )
  end

  defp render_medical_credentials(credentials) do
    %Proto.SpecialistProfileV2.MedicalCredentialsV2{
      board_certification_url: credentials.board_certification_url,
      board_certification_expiry_date:
        credentials.board_certification_expiry_date |> Web.View.Generics.render_datetime(),
      current_state_license_number_url: credentials.current_state_license_number_url,
      current_state_license_number_expiry_date:
        credentials.current_state_license_number_expiry_date
        |> Web.View.Generics.render_datetime()
    }
  end

  defp render_medical_categories(categories) do
    categories
    |> Enum.map(fn category ->
      %Proto.MedicalCategories.MedicalCategoryBase{
        id: category.id,
        name: category.name,
        parent_category_id: category.parent_category_id
      }
    end)
  end

  defp parse_gender(gender) do
    gender |> String.to_existing_atom() |> Proto.Generics.Gender.value()
  end

  defp parse_medical_title(medical_title) do
    medical_title |> String.to_existing_atom() |> Proto.Generics.MedicalTitle.value()
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
