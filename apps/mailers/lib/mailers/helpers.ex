defmodule Mailers.Helpers do
  require Timex.Timezone

  @utc_timezone "Etc/UTC"

  def humanize_datetime(timestamp, user_timezone) when is_integer(timestamp) do
    {:ok, datetime} = DateTime.from_unix(timestamp)

    humanize_datetime(datetime, user_timezone)
  end

  def humanize_datetime(%NaiveDateTime{} = naive_datetime, user_timezone) do
    {:ok, datetime} = DateTime.from_naive(naive_datetime, @utc_timezone)

    humanize_datetime(datetime, user_timezone)
  end

  def humanize_datetime(datetime, user_timezone) do
    _user_timezone = parse_timezone(user_timezone)

    formatted_datetime =
      datetime
      |> Timex.Timezone.convert(user_timezone)
      |> Calendar.strftime("%y-%m-%d %I:%M:%S %p")

    "#{formatted_datetime}"
  end

  def format_specialist(first_name, second_name, medical_title) do
    formatted_medical_title =
      case medical_title do
        nil -> nil
        "UNKNOWN_MEDICAL_TITLE" -> nil
        title -> String.replace(title, "_", ".")
      end

    [formatted_medical_title, first_name, second_name]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp parse_timezone(user_timezone) when user_timezone == "" or is_nil(user_timezone),
    do: @utc_timezone

  defp parse_timezone(user_timezone), do: user_timezone
end
