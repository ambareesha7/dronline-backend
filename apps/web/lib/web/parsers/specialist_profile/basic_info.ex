defmodule Web.Parsers.SpecialistProfile.BasicInfo do
  @unknown_gender [0, Proto.Generics.Gender.key(0)]
  @unknown_title [0, Proto.Generics.Title.key(0)]

  @spec to_map_params(Proto.SpecialistProfile.BasicInfo.t()) :: map
  def to_map_params(%Proto.SpecialistProfile.BasicInfo{} = proto) do
    %{
      first_name: proto.first_name,
      last_name: proto.last_name,
      phone_number: proto.phone_number,
      image_url: proto.image_url,
      birth_date: proto.birth_date |> timestamp_to_date(),
      medical_title: proto.medical_title |> to_string()
    }
    |> add_title_and_gender(proto)
  end

  defp add_title_and_gender(params, %{title: title, gender: gender})
       when title in @unknown_title and gender in @unknown_gender do
    Map.merge(params, %{title: nil, gender: nil})
  end

  defp add_title_and_gender(params, %{gender: gender} = proto) when gender in @unknown_gender do
    Map.merge(params, %{
      title: proto.title |> parse_title() |> to_string(),
      gender: proto.title |> parse_title() |> title_to_gender()
    })
  end

  defp add_title_and_gender(params, proto) do
    Map.merge(params, %{
      title: proto.gender |> parse_gender() |> gender_to_title(),
      gender: proto.gender |> parse_gender() |> to_string()
    })
  end

  defp title_to_gender(:MR), do: "MALE"
  defp title_to_gender(:MRS), do: "FEMALE"
  defp title_to_gender(:MS), do: "FEMALE"

  defp gender_to_title(:MALE), do: "MR"
  defp gender_to_title(:FEMALE), do: "MS"
  defp gender_to_title(:OTHER), do: "MR"

  def timestamp_to_date(nil), do: nil

  def timestamp_to_date(%{timestamp: timestamp}) do
    timestamp |> Timex.from_unix(:second) |> Timex.to_date()
  end

  defp parse_title(title) when is_atom(title), do: title
  defp parse_title(title), do: title |> Proto.Generics.Title.key()

  defp parse_gender(gender) when is_atom(gender), do: gender
  defp parse_gender(gender), do: gender |> Proto.Generics.Gender.key()
end