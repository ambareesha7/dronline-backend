defmodule Web.FallbackController do
  use Web, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(422)
    |> put_view(Web.ErrorView)
    |> render("error_response.proto", changeset: changeset)
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(422)
    |> put_view(Web.ErrorView)
    |> render("error_response.proto", message: message)
  end

  def call(conn, {:error, :unauthorized}) do
    conn |> send_resp(401, "")
  end

  def call(conn, {:error, :forbidden}) do
    conn |> send_resp(403, "")
  end

  def call(conn, {:error, :not_found}) do
    conn |> send_resp(404, "")
  end

  def call(conn, nil) do
    conn |> send_resp(404, "Not found")
  end
end
