defmodule SpecialistProfile.Factory do
  defp random_string, do: System.unique_integer() |> to_string()

  def insert(type, params \\ %{})

  def insert(:basic_info, params) do
    default = %{
      title: "MR",
      gender: "MALE",
      first_name: random_string(),
      last_name: random_string(),
      birth_date: Timex.now() |> Timex.shift(years: -23),
      image_url: random_string(),
      phone_number: random_string()
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, basic_info} = SpecialistProfile.update_basic_info(params, params[:specialist_id])

    basic_info
  end

  def insert(:bio, params) do
    default = %{
      description: random_string(),
      education: [
        %{
          school: "Test University",
          field_of_study: "Test Surgery",
          degree: "PhD",
          start_year: 2010,
          end_year: 2016
        }
      ],
      work_experience: [
        %{
          institution: "Test Hospital",
          position: "Test Surgeon",
          start_year: 2010,
          end_year: 2016
        }
      ]
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, bio_entry} = SpecialistProfile.update_bio(params[:specialist_id], params)

    bio_entry
  end

  def insert(:prices, params) do
    default = %{
      price_minutes_15: 9,
      price_minutes_30: 99,
      price_minutes_45: 999,
      price_minutes_60: 9_999,
      price_second_opinion: 99_999,
      price_in_office: 1000,
      currency: "AED",
      currency_in_office: "AED",
      specialist_id: 1,
      medical_category_id: 1
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, prices} = SpecialistProfile.update_prices(params[:specialist_id], params)

    prices
  end

  def insert(:location, params) do
    default = %{
      street: random_string(),
      number: random_string(),
      postal_code: random_string(),
      city: random_string(),
      country: random_string(),
      neighborhood: random_string(),
      formatted_address: random_string(),
      coordinates: %{
        lat: 80.00001,
        lon: 20.00001
      }
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, location} = SpecialistProfile.update_location(params, params[:specialist_id])

    location
  end

  def insert(:medical_category, params) do
    default = %{
      name: random_string(),
      disabled: false
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, category} =
      Postgres.Repo.insert(
        Map.merge(%SpecialistProfile.MedicalCategories.MedicalCategory{}, params)
      )

    category
  end

  def insert(:medical_credentials, params) do
    default = %{
      dea_number_url: random_string(),
      dea_number_expiry_date: ~D[2222-02-22],
      board_certification_url: random_string(),
      board_certification_expiry_date: ~D[2222-02-22],
      current_state_license_number_url: random_string(),
      current_state_license_number_expiry_date: ~D[2222-02-22]
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, medical_credentials} =
      SpecialistProfile.update_medical_credentials(params, params[:specialist_id])

    medical_credentials
  end
end
