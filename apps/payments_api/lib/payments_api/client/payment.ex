defmodule PaymentsApi.Client.Payment do
  @type ref :: String.t() | integer()
  @type user_data :: %{
          email: String.t(),
          first_name: String.t(),
          last_name: String.t()
        }
  @spec get_payment_url(%{
          amount: String.t(),
          currency: String.t(),
          description: String.t(),
          host: binary(),
          ref: ref,
          user_data: user_data
        }) ::
          {:error, %{code: String.t(), message: String.t()}}
          | {:ok, %{payment_url: String.t(), ref: ref}}
  def get_payment_url(params) do
    config = telr_config()
    url = config[:hosted_payment_api_url]
    updated_params = Map.put(params, :config, config)

    json_body = body(updated_params)

    middleware()
    |> Tesla.client()
    |> Tesla.post(url, json_body)
    |> handle_response()
  end

  defp handle_response(
         {:ok,
          %{
            status: 200,
            body: %{
              "method" => "create",
              "order" => %{
                "ref" => ref,
                "url" => payment_url
              }
            }
          }}
       ) do
    {:ok, %{payment_url: payment_url, ref: ref}}
  end

  defp handle_response(
         {:ok,
          %{
            status: 200,
            body: %{
              "method" => "create",
              "error" => %{
                "message" => error_code,
                "note" => error_message
              }
            }
          }}
       ) do
    {:error, %{code: error_code, message: error_message}}
  end

  defp body(params) do
    %{
      currency: currency,
      amount: amount,
      ref: ref,
      description: description,
      config: config,
      host: host,
      user_data: user_data
    } = params

    success_redirect_url =
      "#{landing_page_url(host)}/order-confirmation?reference=#{ref}&statuscode=200"

    failure_redirect_url =
      "#{landing_page_url(host)}/order-confirmation?reference=#{ref}&statuscode=422"

    %{
      method: "create",
      store: "#{config[:store_id]}" |> String.to_integer(),
      authkey: "#{config[:payment_authkey]}",
      framed: 0,
      order: %{
        cartid: ref,
        test: "#{config[:test_env]}",
        amount: "#{format_amount(amount)}",
        currency: currency,
        description: description
      },
      return: %{
        authorised: success_redirect_url,
        declined: failure_redirect_url,
        cancelled: failure_redirect_url
      },
      customer: %{
        email: user_data.email,
        name: %{
          forenames: user_data.first_name,
          surname: user_data.last_name
        },
        ref: ref
      }
    }
  end

  defp middleware do
    [
      Tesla.Middleware.Logger,
      {Tesla.Middleware.Headers,
       [
         {"Content-Type", "application/json"},
         {"accept", "application/json"}
       ]},
      Tesla.Middleware.Logger,
      Tesla.Middleware.JSON
    ]
  end

  defp format_amount(amount), do: "#{amount}.00"

  defp telr_config, do: Application.get_env(:visits, :telr)

  # TODO: remove switching domain to .ai after all services will be migrated to .ai
  defp landing_page_url(host) do
    if host =~ "dronline.me" do
      Application.get_env(:firebase, :landing_page_url)
    else
      String.replace(Application.get_env(:firebase, :landing_page_url), ".me", ".ai")
    end
  end
end
