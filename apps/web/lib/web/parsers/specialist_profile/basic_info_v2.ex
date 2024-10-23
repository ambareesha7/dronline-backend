defmodule Web.Parsers.SpecialistProfile.BasicInfoV2 do
  def to_map_params(%Proto.SpecialistProfileV2.BasicInfoV2{} = proto) do
    %{
      first_name: proto.first_name,
      last_name: proto.last_name,
      gender: parse_gender(proto.gender),
      title: parse_title(proto.gender),
      birth_date: proto.birth_date |> timestamp_to_date(),
      image_url: proto.profile_image_url,
      medical_title: proto.medical_title |> to_string(),
      phone_number: proto.phone_number,
      address: parse_address(proto.address)
    }
  end

  @unknown_gender Proto.Generics.Gender.key(0)
  defp parse_gender(@unknown_gender), do: nil
  defp parse_gender(gender), do: gender |> to_string()

  defp parse_title(@unknown_gender), do: nil
  defp parse_title(gender), do: gender |> gender_to_title()

  defp gender_to_title(:MALE), do: "MR"
  defp gender_to_title(:FEMALE), do: "MS"
  defp gender_to_title(:OTHER), do: "MR"

  defp timestamp_to_date(nil), do: nil

  defp timestamp_to_date(%{timestamp: timestamp}) do
    timestamp |> Timex.from_unix(:second) |> Timex.to_date()
  end

  defp parse_address(nil), do: nil
  defp parse_address(address), do: Map.from_struct(address)
end
