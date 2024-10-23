defmodule UrgentCare.AreaDispatch do
  @moduledoc """
  Searches for hospitals/clinics that handle calls in patient's area.
  """

  @radius_in_meters 1_000_000

  @spec team_ids_in_area(map) :: [pos_integer()]
  def team_ids_in_area(%{latitude: _lat, longitude: _lon} = position) do
    if FeatureFlags.enabled?("default_urgent_care_clinic") do
      [default_team_id()]
    else
      position
      |> Teams.teams_in_area(distance_in_meters: @radius_in_meters)
      |> Enum.map(& &1.id)
    end
  end

  def closest_clinic_or_hospital(%{latitude: _, longitude: _} = position) do
    if FeatureFlags.enabled?("default_urgent_care_clinic") do
      Teams.get(default_team_id())
    else
      position
      |> Teams.teams_in_area(distance_in_meters: @radius_in_meters)
      |> first()
    end
  end

  defp first([]), do: nil
  defp first(list), do: hd(list)

  def default_team_id do
    {id, _} = :urgent_care |> Application.get_env(:default_clinic_id) |> Integer.parse()
    id
  end
end
