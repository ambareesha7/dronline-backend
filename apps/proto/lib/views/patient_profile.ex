defmodule Proto.PatientProfileView do
  use Proto.View

  def render("address.proto", %{address: address}) do
    %{
      street: address.street,
      home_number: address.home_number,
      additional_numbers: address.additional_numbers,
      neighborhood: address.neighborhood,
      zip_code: address.zip_code,
      city: address.city,
      country: address.country
    }
    |> Proto.validate!(Proto.PatientProfile.Address)
    |> Proto.PatientProfile.Address.new()
  end

  def render("basic_info.proto", %{basic_info: basic_info}) do
    %{
      avatar_url: basic_info.avatar_url,
      title: basic_info.title |> parse_title(),
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      birth_date:
        render_one(basic_info.birth_date |> parse_timestamp, Proto.GenericsView, "datetime.proto",
          as: :datetime
        ),
      email: basic_info.email,
      join_date: fetch_join_date(basic_info)
    }
    |> Proto.validate!(Proto.PatientProfile.BasicInfo)
    |> Proto.PatientProfile.BasicInfo.new()
  end

  def render("blood_pressure.proto", %{blood_pressure: blood_pressure}) do
    %{
      systolic: blood_pressure.systolic,
      diastolic: blood_pressure.diastolic,
      pulse: blood_pressure.pulse
    }
    |> Proto.validate!(Proto.PatientProfile.BloodPressure)
    |> Proto.PatientProfile.BloodPressure.new()
  end

  def render("bmi.proto", %{bmi: bmi}) do
    %{
      height: render_one(bmi.height, Proto.GenericsView, "height.proto", as: :height),
      weight: render_one(bmi.weight, Proto.GenericsView, "weight.proto", as: :weight)
    }
    |> Proto.validate!(Proto.PatientProfile.BMI)
    |> Proto.PatientProfile.BMI.new()
  end

  defp parse_title(nil), do: nil

  defp parse_title(title),
    do: title |> String.to_existing_atom() |> Proto.enum(Proto.Generics.Title)

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(timestamp),
    do: %Proto.Generics.DateTime{
      timestamp: Timex.to_unix(timestamp)
    }

  defp fetch_join_date(%{patient: %{inserted_at: join_date}}), do: join_date |> Timex.to_unix()
  defp fetch_join_date(_), do: nil
end
