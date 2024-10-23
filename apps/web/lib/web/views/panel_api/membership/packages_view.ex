defmodule Web.PanelApi.Membership.PackagesView do
  use Web, :view

  def render("index.proto", %{packages: packages}) do
    %{
      packages: render_many(packages, Proto.MembershipView, "package.proto", as: :package)
    }
    |> Proto.validate!(Proto.Membership.GetPackagesListResponse)
    |> Proto.Membership.GetPackagesListResponse.new()
  end
end
