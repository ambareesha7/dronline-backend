defmodule Web.PanelApi.Membership.SubscriptionView do
  use Web, :view

  def render("show.proto", %{
        active_package: active_package,
        expires_at: expires_at,
        next_package: next_package
      }) do
    %{
      active_package:
        render_one(active_package, Proto.MembershipView, "active_package.proto", as: :package),
      expires_at: render_one(expires_at, Proto.GenericsView, "datetime.proto", as: :datetime),
      next_package: render_one(next_package, Proto.MembershipView, "package.proto", as: :package)
    }
    |> Proto.validate!(Proto.Membership.GetActivePackageResponse)
    |> Proto.Membership.GetActivePackageResponse.new()
  end

  def render("pending_subscription.proto", %{pending_subscription: pending_subscription}) do
    %{
      redirect_url: pending_subscription.webview_url
    }
    |> Proto.validate!(Proto.Membership.GetPendingSubscriptionResponse)
    |> Proto.Membership.GetPendingSubscriptionResponse.new()
  end

  def render("subscribe.proto", %{redirect_url: redirect_url}) do
    %{
      redirect_url: redirect_url
    }
    |> Proto.validate!(Proto.Membership.SubscribeResponse)
    |> Proto.Membership.SubscribeResponse.new()
  end

  def render("verify.proto", %{status: status}) do
    %{
      status: Proto.enum(status, Proto.Membership.VerifyResponse.Status)
    }
    |> Proto.validate!(Proto.Membership.VerifyResponse)
    |> Proto.Membership.VerifyResponse.new()
  end
end
