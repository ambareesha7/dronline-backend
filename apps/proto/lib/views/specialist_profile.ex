defmodule Proto.SpecialistProfileView do
  use Proto.View

  def render("credentials.proto", %{credentials: credentials}) do
    %{
      email: credentials.email,
      id: credentials.id
    }
    |> Proto.validate!(Proto.SpecialistProfile.Credentials)
    |> Proto.SpecialistProfile.Credentials.new()
  end

  def render("basic_info.proto", %{basic_info: basic_info}) do
    %{
      title: basic_info.title |> Proto.enum(Proto.Generics.Title),
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      birth_date:
        render_one(basic_info.birth_date, Proto.GenericsView, "datetime.proto", as: :datetime),
      image_url: basic_info.image_url,
      phone_number: basic_info.phone_number
    }
    |> Proto.validate!(Proto.SpecialistProfile.BasicInfo)
    |> Proto.SpecialistProfile.BasicInfo.new()
  end

  def render("medical_credentials.proto", %{medical_credentials: medical_credentials}) do
    %{
      dea_number_url: medical_credentials.dea_number_url,
      dea_number_expiry_date:
        render_one(
          medical_credentials.dea_number_expiry_date,
          Proto.GenericsView,
          "datetime.proto",
          as: :datetime
        ),
      board_certification_url: medical_credentials.board_certification_url,
      board_certification_expiry_date:
        render_one(
          medical_credentials.board_certification_expiry_date,
          Proto.GenericsView,
          "datetime.proto",
          as: :datetime
        ),
      current_state_license_number_url: medical_credentials.current_state_license_number_url,
      current_state_license_number_expiry_date:
        render_one(
          medical_credentials.current_state_license_number_expiry_date,
          Proto.GenericsView,
          "datetime.proto",
          as: :datetime
        )
    }
    |> Proto.validate!(Proto.SpecialistProfile.MedicalCredentials)
    |> Proto.SpecialistProfile.MedicalCredentials.new()
  end

  def render("medical_info.proto", %{medical_info: medical_info}) do
    %{
      medical_categories:
        render_many(
          medical_info.medical_categories,
          Proto.MedicalCategoriesView,
          "medical_category_base.proto",
          as: :medical_category
        ),
      medical_credentials:
        render_one(
          medical_info.medical_credentials,
          Proto.SpecialistProfileView,
          "medical_credentials.proto",
          as: :medical_credentials
        )
    }
    |> Proto.validate!(Proto.SpecialistProfile.MedicalInfo)
    |> Proto.SpecialistProfile.MedicalInfo.new()
  end

  def render("location.proto", %{location: location}) do
    %{
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
    |> Proto.validate!(Proto.SpecialistProfile.Location)
    |> Proto.SpecialistProfile.Location.new()
  end

  def render("status.proto", %{status: status}) do
    %{
      approval_status:
        status.approval_status |> Proto.enum(Proto.SpecialistProfile.Status.ApprovalStatus),
      onboarding_completed: status.onboarding_completed,
      package_type: status.package_type |> Proto.enum(Proto.SpecialistProfile.Status.PackageType),
      trial_ends_at:
        status.trial_ends_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix(),
      has_seen_pricing_tables: status.has_seen_pricing_tables
    }
    |> Proto.validate!(Proto.SpecialistProfile.Status)
    |> Proto.SpecialistProfile.Status.new()
  end

  def render("category_prices.proto", %{category_prices: category_prices}) do
    %{
      price_minutes_15: category_prices.price_minutes_15,
      price_minutes_30: category_prices.price_minutes_30,
      price_minutes_45: category_prices.price_minutes_45,
      price_minutes_60: category_prices.price_minutes_60,
      price_second_opinion: category_prices.price_second_opinion,
      price_in_office: category_prices.price_in_office,
      currency_in_office: category_prices.currency_in_office,
      prices_enabled: category_prices.prices_enabled,
      currency: category_prices.currency,
      medical_category_id: category_prices.medical_category_id,
      medical_category_name: category_prices.medical_category.name,
      medical_category_image_url: category_prices.medical_category.image_url
    }
    |> Proto.validate!(Proto.SpecialistProfile.CategoryPricesResponse)
    |> Proto.SpecialistProfile.CategoryPricesResponse.new()
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
