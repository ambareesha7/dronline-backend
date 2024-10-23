defmodule Firebase.DynamicLinks do
  import Mockery.Macro

  alias Firebase.DynamicLinks.Backend

  @spec generate(String.t(), Keyword.t()) :: {:ok, String.t()} | :error
  def generate(payload, options \\ []) do
    Sentry.Context.set_extra_context(%{generate_payload: payload})

    case mockable(Backend, by: Firebase.DynamicLinks.BackendMock).generate(payload, options) do
      {:ok, %Tesla.Env{status: 200, body: %{"shortLink" => short_link}}} ->
        {:ok, short_link}

      result ->
        Sentry.Context.set_extra_context(%{result: result})
        :error
    end
  end
end
