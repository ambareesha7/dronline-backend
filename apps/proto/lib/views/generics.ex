defmodule Proto.GenericsView do
  use Proto.View

  def render("datetime.proto", %{datetime: datetime}) do
    %{
      timestamp: datetime.timestamp
    }
    |> Proto.validate!(Proto.Generics.DateTime)
    |> Proto.Generics.DateTime.new()
  end

  def render("height.proto", %{height: height}) do
    %{
      value: height.value
    }
    |> Proto.validate!(Proto.Generics.Height)
    |> Proto.Generics.Height.new()
  end

  def render("weight.proto", %{weight: weight}) do
    %{
      value: weight.value
    }
    |> Proto.validate!(Proto.Generics.Weight)
    |> Proto.Generics.Weight.new()
  end
end
