defmodule Membership.Subscription.Helpers do
  import Mockery.Macro

  alias Membership.Specialists
  alias Membership.Subscription
  alias Membership.Telr

  @authorised 2
  @paid 3

  @types_order ["BASIC", "SILVER", "GOLD", "PLATINUM"]

  def prepare_check_request_body(subscription) do
    %{
      "method" => "check",
      "order" => %{
        "ref" => subscription.ref
      }
    }
  end

  def subscription_action(%{type: current_type}, current_type), do: :invalid_action

  def subscription_action(%{type: current_type}, new_type) do
    if order_of_type(current_type) < order_of_type(new_type) do
      :upgrade
    else
      :downgrade
    end
  end

  defp order_of_type(type), do: Enum.find_index(@types_order, &(&1 == type))

  # Paid
  def parse_response(%{"order" => %{"status" => %{"code" => code}}} = response)
      when code in [@authorised, @paid] do
    agreement = response["order"]["agreement"]

    update_params = %{
      agreement_id: agreement["id"] |> to_string(),
      day: agreement["recurring"]["day"],
      accepted_at: DateTime.utc_now(),
      last_payment_at: DateTime.utc_now(),
      status: "ACCEPTED"
    }

    {:ok, update_params}
  end

  # Declined
  def parse_response(_) do
    update_params = %{
      declined_at: DateTime.utc_now(),
      status: "DECLINED"
    }

    {:ok, update_params}
  end

  def send_package_update_notification(specialist_id) do
    {:ok, package_type} = Membership.Specialists.Package.fetch_active_type(specialist_id)

    for topic <- ["doctor", "external"] do
      Membership.ChannelBroadcast.push(%{
        topic: topic,
        event: "active_package_update",
        payload: %{
          proto: %Proto.Membership.ActivePackageUpdate{
            type: package_type
          },
          external_id: specialist_id
        }
      })
    end
  end

  def end_active_subscription(active_subscription) do
    {:ok, _response} =
      mockable(Telr.Tools, by: Telr.ToolsMock).cancel_agreement(active_subscription.agreement_id)

    {:ok, _subscription} =
      Subscription.update(active_subscription.id, %{
        status: "ENDED",
        ended_at: Timex.now()
      })

    :ok
  end

  def cancel_active_subscription(active_subscription) do
    {:ok, _response} =
      mockable(Telr.Tools, by: Telr.ToolsMock).cancel_agreement(active_subscription.agreement_id)

    {:ok, _subscription} =
      Subscription.update(active_subscription.id, %{
        status: "CANCELLED",
        cancelled_at: Timex.now()
      })

    :ok
  end

  def cancel_waiting_subscription(specialist_id) do
    case Specialists.Subscription.fetch_accepted(specialist_id) do
      {:ok, waiting_subscription} ->
        {:ok, _response} =
          mockable(Telr.Tools, by: Telr.ToolsMock).cancel_agreement(
            waiting_subscription.agreement_id
          )

        {:ok, _subscription} =
          Subscription.update(waiting_subscription.id, %{
            status: "CANCELLED",
            cancelled_at: Timex.now()
          })

        :ok

      {:error, :not_found} ->
        :ok
    end
  end
end
