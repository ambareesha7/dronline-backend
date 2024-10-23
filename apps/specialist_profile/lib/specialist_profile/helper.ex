defmodule SpecialistProfile.Helper do
  def parse_date(nil), do: nil
  def parse_date(%Date{} = date), do: %{timestamp: Timex.to_unix(date)}
end
