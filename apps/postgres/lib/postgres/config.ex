defmodule Postgres.Config do
  @integer_url_query_params ["timeout", "pool_size"]

  def get_repo_config do
    parsed_url = parse_url(System.get_env("DATABASE_URL") || "")

    :postgres
    |> Application.get_env(Postgres.Repo)
    |> Keyword.merge(parsed_url)
  end

  # Parses an Ecto URL allowed in configuration.
  #
  # The format must be:
  #   "ecto://username:password@hostname:port/database?ssl=true&timeout=1000"

  defp parse_url(""), do: []

  defp parse_url(url) when is_binary(url) do
    info = URI.parse(url)

    if is_nil(info.host) do
      raise Ecto.InvalidURLError, url: url, message: "host is not present"
    end

    if is_nil(info.path) or not (info.path =~ ~r"^/([^/])+$") do
      raise Ecto.InvalidURLError, url: url, message: "path should be a database name"
    end

    destructure [username, password], info.userinfo && String.split(info.userinfo, ":")
    "/" <> database = info.path

    url_opts = [
      username: username,
      password: password,
      database: database,
      hostname: info.host,
      port: info.port
    ]

    query_opts = parse_uri_query(info)

    for {k, v} <- url_opts ++ query_opts,
        not is_nil(v),
        do: {k, if(is_binary(v), do: URI.decode(v), else: v)}
  end

  defp parse_uri_query(%URI{query: nil}), do: []

  defp parse_uri_query(%URI{query: query} = url) do
    query
    |> URI.query_decoder()
    |> Enum.reduce([], fn
      {"ssl", "true"}, acc ->
        [{:ssl, true}] ++ acc

      {"ssl", "false"}, acc ->
        [{:ssl, false}] ++ acc

      {key, value}, acc when key in @integer_url_query_params ->
        [{String.to_existing_atom(key), parse_integer!(key, value, url)}] ++ acc

      {key, _value}, _acc ->
        raise Ecto.InvalidURLError, url: url, message: "unsupported query parameter `#{key}`"
    end)
  end

  defp parse_integer!(key, value, url) do
    case Integer.parse(value) do
      {int, ""} ->
        int

      _ ->
        raise Ecto.InvalidURLError,
          url: url,
          message: "can not parse value `#{value}` for parameter `#{key}` as an integer"
    end
  end
end
