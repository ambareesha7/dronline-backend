defmodule Web.Parsers.PatientProfile.BasicInfoParamsTest do
  use ExUnit.Case, async: true

  alias Web.Parsers.PatientProfile.BasicInfoParams

  # protobuf enum values
  @unknown 0
  @known 1

  defp random_string, do: System.unique_integer() |> to_string

  defp to_proto(variable_part) do
    params = Enum.into(variable_part, %{})

    Map.merge(Proto.PatientProfile.BasicInfoParams.new(), params)
  end

  test "returns first_name as is" do
    proto = to_proto(first_name: random_string())

    assert BasicInfoParams.to_map_params(proto).first_name == proto.first_name
  end

  test "returns last_name as is" do
    proto = to_proto(last_name: random_string())

    assert BasicInfoParams.to_map_params(proto).last_name == proto.last_name
  end

  test "returns email as is" do
    proto = to_proto(email: random_string())

    assert BasicInfoParams.to_map_params(proto).email == proto.email
  end

  test "returns Date when birth_date is provided" do
    date = ~D[1990-05-05]

    proto = to_proto(birth_date: %Proto.Generics.DateTime{timestamp: Timex.to_unix(date)})

    assert BasicInfoParams.to_map_params(proto).birth_date == date
  end

  test "returns nil when birth_date isn't provided" do
    proto = to_proto(birth_date: nil)

    assert BasicInfoParams.to_map_params(proto).birth_date == nil
  end

  test "returns avatar_resource_path as is when it is provided" do
    proto = to_proto(avatar_resource_path: random_string())

    assert BasicInfoParams.to_map_params(proto).avatar_resource_path == proto.avatar_resource_path
  end

  test "doesn't return avatar_resource_path when it isn't provided" do
    proto = to_proto(avatar_resource_path: "")

    refute proto |> BasicInfoParams.to_map_params() |> Map.has_key?(:avatar_resource_path)
  end

  test "returns nils when both title and gender wasn't provided" do
    proto = to_proto(title: @unknown, gender: @unknown)

    map_params = BasicInfoParams.to_map_params(proto)

    assert map_params.title == nil
    assert map_params.gender == nil
  end

  test "returns binary title and gender when gender is provided" do
    proto = to_proto(gender: @known)

    map_params = BasicInfoParams.to_map_params(proto)

    assert is_binary(map_params.title)
    assert is_binary(map_params.gender)
  end

  test "returns binary title and gender when title is provided" do
    proto = to_proto(title: @known)

    map_params = BasicInfoParams.to_map_params(proto)

    assert is_binary(map_params.title)
    assert is_binary(map_params.gender)
  end
end
