defmodule Web.ErrorView do
  use Web, :view

  def render("error_response.proto", %{changeset: changeset}) do
    message = changeset |> Web.ErrorHelpers.errors_from_changeset() |> Enum.join(",\n")

    %{
      simple_error: render_one(message, __MODULE__, "simple_error.proto", as: :simple_error),
      form_errors: render_one(changeset.errors, __MODULE__, "form_errors.proto", as: :form_errors)
    }
    |> Proto.validate!(Proto.Errors.ErrorResponse)
    |> Proto.Errors.ErrorResponse.new()
  end

  def render("error_response.proto", %{message: message}) do
    %{
      simple_error: render_one(message, __MODULE__, "simple_error.proto", as: :simple_error)
    }
    |> Proto.validate!(Proto.Errors.ErrorResponse)
    |> Proto.Errors.ErrorResponse.new()
  end

  def render("form_errors.proto", %{form_errors: form_errors}) do
    %{
      field_errors: render_many(form_errors, __MODULE__, "field_error.proto", as: :field_error)
    }
    |> Proto.validate!(Proto.Errors.FormErrors)
    |> Proto.Errors.FormErrors.new()
  end

  def render("field_error.proto", %{field_error: {field, raw_message}}) do
    %{
      field: to_string(field),
      message: Web.ErrorHelpers.translate_error(raw_message)
    }
    |> Proto.validate!(Proto.Errors.FormErrors.FieldError)
    |> Proto.Errors.FormErrors.FieldError.new()
  end

  def render("simple_error.proto", %{simple_error: simple_error}) do
    %{message: simple_error}
    |> Proto.validate!(Proto.Errors.SimpleError)
    |> Proto.Errors.SimpleError.new()
  end

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Proto.Errors.ErrorResponse.new(
      simple_error:
        Proto.Errors.SimpleError.new(
          message: Phoenix.Controller.status_message_from_template(template)
        )
    )
  end
end
