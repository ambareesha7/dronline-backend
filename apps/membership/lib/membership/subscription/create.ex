defmodule Membership.Subscription.Create do
  import Mockery.Macro

  alias Membership.Specialists
  alias Membership.Subscription
  alias Membership.Subscription.Helpers
  alias Membership.Telr

  @types_order ["BASIC", "SILVER", "GOLD", "PLATINUM"]

  @spec call(non_neg_integer, String.t()) ::
          {:ok, String.t() | nil} | {:error, :invalid_action} | {:error, :wrong_package_type}
  def call(specialist_id, type) when type in @types_order do
    with {:ok, active_subscription} <- Specialists.Subscription.fetch_active(specialist_id) do
      case Helpers.subscription_action(active_subscription, type) do
        :upgrade ->
          handle_upgrade(specialist_id, type, active_subscription)

        :downgrade ->
          handle_downgrade(specialist_id, type, active_subscription)

        :invalid_action ->
          {:error, :invalid_action}
      end
    else
      {:error, :not_found} ->
        create_subscription(specialist_id, type)
    end
  end

  def call(_specialist_id, _type), do: {:error, :wrong_package_type}

  def handle_upgrade(specialist_id, type, _active_subscription) do
    create_subscription(specialist_id, type)
  end

  def handle_downgrade(specialist_id, type, active_subscription) do
    case Specialists.Subscription.fetch_accepted(specialist_id) do
      {:ok, %{type: ^type}} ->
        {:error, :invalid_action}

      _ ->
        create_downgraded_subscription(specialist_id, type, active_subscription.next_payment_date)
    end
  end

  defp create_subscription(_specialist_id, "BASIC") do
    {:ok, nil}
  end

  defp create_subscription(specialist_id, type) do
    order_id = UUID.uuid4(:hex)

    with {:ok, specialist_data} <- Specialists.fetch_by_id(specialist_id),
         {:ok, package} <- Membership.fetch_package(type),
         next_payment_date <- calculate_next_payment_date(),
         body <- prepare_request_body(specialist_data, order_id, package, next_payment_date),
         {:ok, response} <- mockable(Telr.Gateway, by: Telr.GatewayMock).send(body),
         {:ok, _} <- abandon_existing_pending_subscription(specialist_id),
         {:ok, _subscription} <-
           create_subscription_entry(specialist_id, type, order_id, response, next_payment_date) do
      {:ok, response["order"]["url"]}
    end
  end

  defp create_downgraded_subscription(specialist_id, "BASIC", _next_payment_date) do
    _ = Membership.Subscription.Cancel.call(specialist_id)

    {:ok, nil}
  end

  defp create_downgraded_subscription(specialist_id, type, next_payment_date) do
    order_id = UUID.uuid4(:hex)

    with {:ok, specialist_data} <- Specialists.fetch_by_id(specialist_id),
         {:ok, package} <- Membership.fetch_package(type),
         body <-
           prepare_request_body(specialist_data, order_id, package, next_payment_date, :downgrade),
         {:ok, response} <- mockable(Telr.Gateway, by: Telr.GatewayMock).send(body),
         {:ok, _subscription} <-
           create_subscription_entry(specialist_id, type, order_id, response, next_payment_date) do
      {:ok, response["order"]["url"]}
    end
  end

  defp create_subscription_entry(specialist_id, type, order_id, response, next_payment_date) do
    %{"ref" => ref, "url" => webview_url} = response["order"]

    params = %{
      order_id: order_id,
      next_payment_date: next_payment_date,
      ref: ref,
      specialist_id: specialist_id,
      status: "PENDING",
      type: type,
      webview_url: webview_url
    }

    Subscription.create(params)
  end

  defp abandon_existing_pending_subscription(specialist_id) do
    Subscription.abandon_existing_pending(specialist_id)
  end

  defp calculate_next_payment_date do
    Timex.today()
    |> Timex.shift(months: 1)
  end

  defp prepare_request_body(specialist_data, order_id, package, next_payment_date, mode \\ :new) do
    panel_url = :web |> Application.get_env(:specialist_panel_url) |> URI.parse()

    %{
      "method" => "create",
      "order" => %{
        "cartid" => order_id,
        "test" => :membership |> Application.get_env(:test_env) |> String.to_integer(),
        "amount" => initial_amount(mode, package.price),
        "currency" => "aed",
        "description" => "Payment for DrOnline service - #{package.name} package"
      },
      "return" => %{
        "authorised" => panel_url |> URI.merge("/membership/verify/#{order_id}") |> to_string(),
        "declined" => panel_url |> URI.merge("/membership/verify/#{order_id}") |> to_string(),
        "cancelled" => panel_url |> URI.merge("/membership/verify/#{order_id}") |> to_string()
      },
      "repeat" => %{
        "amount" => package.price,
        "interval" => 1,
        "period" => "M",
        "term" => 0,
        "final" => 0.00,
        "start" => Timex.format!(next_payment_date, "{0D}{0M}{0YYYY}")
      },
      "customer" => %{
        "email" => specialist_data.email,
        "name" => %{
          "forenames" => specialist_data.first_name,
          "surname" => specialist_data.last_name
        },
        "address" => %{
          "line1" => "#{specialist_data.street} #{specialist_data.number}",
          "city" => specialist_data.city,
          "country" => specialist_data.country
        },
        "ref" => specialist_data.id |> to_string()
      }
    }
  end

  defp initial_amount(:downgrade, _price), do: 1.00
  defp initial_amount(_type, price), do: price
end
