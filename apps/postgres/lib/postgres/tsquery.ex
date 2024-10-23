defmodule Postgres.TSQuery do
  use Postgres.Service

  def filter(query, filter, opts) when is_binary(filter) and filter != "" do
    tsquery = filter |> split_words() |> to_tsquery()

    filter_table = Keyword.fetch!(opts, :join)
    join_field = Keyword.fetch!(opts, :on)

    query
    |> join(:left, [b], fd in ^filter_table, on: b.id == field(fd, ^join_field))
    |> where([..., fd], fragment("? @@ to_tsquery('simple', ?)", fd.filter_data, ^tsquery))
  end

  def filter(query, _filter, _opts) do
    query
  end

  defp split_words(string), do: string |> String.split(~r/\s+/) |> Enum.reject(&(&1 == ""))
  defp to_tsquery(words), do: words |> Enum.map_join(" & ", &(&1 <> ":*"))
end
