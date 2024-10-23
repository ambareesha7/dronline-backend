defmodule Membership.Telr.Tools do
  use Tesla, docs: false

  plug(Tesla.Middleware.BaseUrl, Application.get_env(:membership, :tools_url))

  plug(Tesla.Middleware.BasicAuth,
    username: Application.get_env(:membership, :basic_auth_name),
    password: Application.get_env(:membership, :basic_auth_password)
  )

  @spec get_agreement(String.t()) :: {:ok, map} | :error
  def get_agreement(id) do
    "/agreement/#{id}"
    |> get()
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        parsed_body = XmlToMap.naive_map(body)

        {:ok, parsed_body}

      failure ->
        _ = Sentry.Context.set_extra_context(%{failure: failure})
        _ = Sentry.capture_message("Membership.Telr.Tools.get_agreement/1 failure")

        :error
    end
  end

  @spec get_agreement_history(String.t()) :: {:ok, map} | :error
  def get_agreement_history(id) do
    "/agreement/#{id}/history"
    |> get()
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        parsed_body = XmlToMap.naive_map(body)

        {:ok, parsed_body}

      failure ->
        _ = Sentry.Context.set_extra_context(%{failure: failure})
        _ = Sentry.capture_message("Membership.Telr.Tools.get_agreement_history/1 failure")

        :error
    end
  end

  @spec cancel_agreement(String.t()) :: {:ok, map} | :error
  def cancel_agreement(id) do
    "/agreement/#{id}"
    |> delete()
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        parsed_body = XmlToMap.naive_map(body)

        {:ok, parsed_body}

      failure ->
        _ = Sentry.Context.set_extra_context(%{failure: failure})
        _ = Sentry.capture_message("Membership.Telr.Tools.cancel_agreement/1 failure")

        :error
    end
  end
end
