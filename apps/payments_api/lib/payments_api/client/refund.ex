defmodule PaymentsApi.Client.Refund do
  @spec refund_visit(
          String.t(),
          non_neg_integer(),
          atom()
        ) ::
          :ok | :error
  def refund_visit(ref, amount, currency) do
    xml_body = body(currency, amount, ref)

    middleware()
    |> Tesla.client()
    |> Tesla.post("", xml_body)
    |> handle_response()
  end

  defp handle_response({:ok, %{body: body}}) do
    parsed_body = XmlToMap.naive_map(body)

    # Authorization status. A indicates an authorized transaction.
    # Any other value indicates that the request could not be processed.
    if get_in(parsed_body, ["remote", "auth", "status"]) == "A" do
      :ok
    else
      handle_response(parsed_body)
    end
  end

  defp handle_response(result) do
    extra = %{result: result}
    Sentry.Context.set_extra_context(extra)

    :error
  end

  defp body(currency, amount, ref) do
    config = telr_config()

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <remote>
      <store>#{config[:store_id]}</store>
      <key>#{config[:authkey]}</key>
      <tran>
        <type>release</type>
        <class>ecom</class>
        <currency>#{currency}</currency>
        <amount>#{format_amount(amount)}</amount>
        <ref>#{ref}</ref>
        <test>#{config[:test_env]}</test>
      </tran>
    </remote>
    """
  end

  defp middleware do
    url = telr_config()[:remote_api_url]

    [
      {Tesla.Middleware.BaseUrl, url},
      Tesla.Middleware.Logger,
      {Tesla.Middleware.Headers,
       [
         {"Content-Type", "application/xml"}
       ]}
    ]
  end

  defp format_amount(amount), do: "#{amount}.00"

  defp telr_config, do: Application.get_env(:visits, :telr)
end
