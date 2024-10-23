defmodule Firebase.Authentication.Client do
  use Tesla, docs: false

  plug(Tesla.Middleware.JSON)

  @url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  @doc """
  Returns google public keys and max age value in milliseconds
  """
  @spec get_keys :: {:ok, public_keys :: map, max_age :: pos_integer} | :error
  def get_keys do
    case get(@url) do
      {:ok, %Tesla.Env{status: 200} = env} ->
        {:ok, env.body, parse_max_age(env)}

      failure ->
        _ = Sentry.Context.set_extra_context(%{failure: failure})
        _ = Sentry.capture_message("Firebase.Authentication.Client.get_keys/0 failure")

        :error
    end
  end

  defp parse_max_age(env) do
    env
    |> Tesla.get_header("cache-control")
    |> String.replace(~r/\A.*max-age=(\d+).*\z/, "\\1")
    |> String.to_integer()
    |> seconds_to_milliseconds()
  end

  defp seconds_to_milliseconds(sec), do: sec * 1000
end
