defmodule Web.ErrorViewTest do
  use Web.ConnCase, async: true
  import Phoenix.View

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.SimpleError

  test "renders 404.proto" do
    assert render(Web.ErrorView, "404.proto", []) == %ErrorResponse{
             simple_error: %SimpleError{message: "Not Found"}
           }
  end

  test "renders 500.proto" do
    assert render(Web.ErrorView, "500.proto", []) == %ErrorResponse{
             simple_error: %SimpleError{message: "Internal Server Error"}
           }
  end
end
