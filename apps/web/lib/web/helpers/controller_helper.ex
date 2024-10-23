defmodule Web.ControllerHelper do
  def next_token_to_string(nil), do: nil
  def next_token_to_string(next_token), do: next_token |> to_string()

  def parse_timestamp(nil), do: nil

  def parse_timestamp(%{timestamp: timestamp}),
    do: timestamp |> Timex.from_unix(:second) |> Timex.to_date()
end
