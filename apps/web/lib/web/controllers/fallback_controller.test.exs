defmodule Web.FallbackControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors
  alias Proto.Errors.FormErrors.FieldError
  alias Proto.Errors.SimpleError

  test "form errors", %{conn: conn} do
    changeset = %Ecto.Changeset{
      errors: [
        city: {"can't be blank", [validation: :required]},
        country: {"can't be blank", [validation: :required]},
        _custom: {"you can have only one custom something", []}
      ]
    }

    conn = Web.FallbackController.call(conn, {:error, changeset})

    assert %ErrorResponse{
             simple_error: %SimpleError{
               message:
                 "City can't be blank,\nCountry can't be blank,\nYou can have only one custom something"
             },
             form_errors: %FormErrors{field_errors: field_errors}
           } = proto_response(conn, 422, ErrorResponse)

    assert %FieldError{field: "city", message: "can't be blank"} in field_errors
    assert %FieldError{field: "country", message: "can't be blank"} in field_errors

    assert %FieldError{
             field: "_custom",
             message: "you can have only one custom something"
           } in field_errors
  end

  test "simple error message", %{conn: conn} do
    message = "something went wrong"
    conn = Web.FallbackController.call(conn, {:error, message})

    assert %ErrorResponse{simple_error: %SimpleError{message: ^message}} =
             proto_response(conn, 422, ErrorResponse)
  end

  test "unauthorized access error", %{conn: conn} do
    conn = Web.FallbackController.call(conn, {:error, :unauthorized})

    assert response(conn, 401)
  end

  test "resource not found error", %{conn: conn} do
    conn = Web.FallbackController.call(conn, {:error, :not_found})

    assert response(conn, 404)
  end
end
