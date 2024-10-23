defmodule Proto.OrderedTestsItemView do
  use Proto.View

  def render("ordered_tests_item.proto", %{ordered_test: ordered_test}) do
    ordered_test
    |> Proto.validate!(Proto.EMR.OrderedTestsItem)
    |> Proto.EMR.OrderedTestsItem.new()
  end
end
