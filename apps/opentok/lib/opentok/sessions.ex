defmodule OpenTok.Sessions do
  @create_endpoint "/session/create"

  defp middleware do
    [
      {Tesla.Middleware.BaseUrl, Application.get_env(:opentok, :api_url)},
      {Tesla.Middleware.Headers,
       [
         {"Accept", "application/json"},
         {"X-OPENTOK-AUTH", OpenTok.Authentication.generate_token()}
       ]},
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.DecodeJson,
      Tesla.Middleware.Logger
    ]
  end

  defp client do
    Tesla.client(middleware())
  end

  @doc """
  Calls OpenTok Session API and if succeeds returns `session_id`
  """
  @spec create(pos_integer) :: {:ok, String.t()}
  def create(record_id) do
    client()
    |> Tesla.post(@create_endpoint, %{"p2p.preference" => "disabled", "archiveMode" => "always"})
    |> case do
      {:ok, %{body: body}} ->
        session_id = parse_response(body)
        :ok = EMR.assign_tokbox_session_to_record(record_id, session_id)

        {:ok, session_id}

      result ->
        extra = %{result: result}
        Sentry.Context.set_extra_context(extra)

        raise "OpenTok.Sessions.create/0 invalid result"
    end
  end

  @doc """
  Calls OpenTok Session API and if succeeds returns `session_id`.
  Used if there's no pre-existing record,
  as it's the case for Specialist->Patient call from EMR page
  """
  @spec create :: {:ok, String.t()}
  def create do
    client()
    |> Tesla.post(@create_endpoint, %{"p2p.preference" => "disabled", "archiveMode" => "always"})
    |> case do
      {:ok, %{body: body}} ->
        session_id = parse_response(body)

        {:ok, session_id}

      result ->
        extra = %{result: result}
        Sentry.Context.set_extra_context(extra)

        raise "OpenTok.Sessions.create/0 invalid result"
    end
  end

  defp parse_response([body]), do: body["session_id"]
end
