defmodule Proto.MembershipView do
  use Proto.View

  def render("package.proto", %{package: package}) do
    %{
      name: package.name,
      price: package.price |> to_string(),
      features: render_many(package.features, __MODULE__, "feature.proto", as: :feature),
      type: package.type
    }
    |> Proto.validate!(Proto.Membership.Package)
    |> Proto.Membership.Package.new()
  end

  def render("active_package.proto", %{package: package}) do
    %{
      name: package.name,
      price: package.price |> to_string(),
      features: render_many(package.included_features, __MODULE__, "feature.proto", as: :feature),
      type: package.type,
      missing_features:
        render_many(package.missing_features, __MODULE__, "feature.proto", as: :feature)
    }
    |> Proto.validate!(Proto.Membership.Package)
    |> Proto.Membership.Package.new()
  end

  def render("feature.proto", %{feature: feature}) do
    %{
      text: feature.text,
      bold: feature.bold,
      description: feature.description
    }
    |> Proto.validate!(Proto.Membership.Package.Feature)
    |> Proto.Membership.Package.Feature.new()
  end
end
