defmodule Web.Parsers.SpecialistProfile.BasicInfoTest do
  use ExUnit.Case, async: true

  alias Web.Parsers.SpecialistProfile.BasicInfo

  # protobuf enum values
  @unknown 0
  @known 1

  defp random_string, do: System.unique_integer() |> to_string

  defp to_proto(variable_part) do
    params = Enum.into(variable_part, %{})

    Map.merge(Proto.SpecialistProfile.BasicInfo.new(), params)
  end

  test "returns first_name as is" do
    proto = to_proto(first_name: random_string())

    assert BasicInfo.to_map_params(proto).first_name == proto.first_name
  end

  test "returns last_name as is" do
    proto = to_proto(last_name: random_string())

    assert BasicInfo.to_map_params(proto).last_name == proto.last_name
  end

  test "returns image_url as is" do
    proto = to_proto(image_url: random_string())

    assert BasicInfo.to_map_params(proto).image_url == proto.image_url
  end

  test "returns phone_number as is" do
    proto = to_proto(phone_number: random_string())

    assert BasicInfo.to_map_params(proto).phone_number == proto.phone_number
  end

  test "returns Date when birth_date is provided" do
    date = ~D[1990-05-05]

    proto = to_proto(birth_date: %Proto.Generics.DateTime{timestamp: Timex.to_unix(date)})

    assert BasicInfo.to_map_params(proto).birth_date == date
  end

  test "returns nil when birth_date isn't provided" do
    proto = to_proto(birth_date: nil)

    assert BasicInfo.to_map_params(proto).birth_date == nil
  end

  test "returns nils when both title and gender wasn't provided" do
    proto = to_proto(title: @unknown, gender: @unknown)

    map_params = BasicInfo.to_map_params(proto)

    assert map_params.title == nil
    assert map_params.gender == nil
  end

  test "returns binary title and gender when gender is provided" do
    proto = to_proto(gender: @known)

    map_params = BasicInfo.to_map_params(proto)

    assert is_binary(map_params.title)
    assert is_binary(map_params.gender)
  end

  test "returns binary title and gender when title is provided" do
    proto = to_proto(title: @known)

    map_params = BasicInfo.to_map_params(proto)

    assert is_binary(map_params.title)
    assert is_binary(map_params.gender)
  end

  test "returns medical_title as binary" do
    proto = to_proto(medical_title: @known)

    map_params = BasicInfo.to_map_params(proto)

    assert is_binary(map_params.medical_title)
  end
end
