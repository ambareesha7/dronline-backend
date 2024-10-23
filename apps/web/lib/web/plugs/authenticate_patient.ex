defmodule Web.Plugs.AuthenticatePatient do
  use Web, :plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    token = conn |> get_req_header("x-auth-token") |> List.first()

    case token && Authentication.authenticate_patient(token) do
      {:ok, patient_id} ->
        conn |> assign(:current_patient_id, patient_id)

      _ ->
        conn
        |> send_resp(401, "")
        |> halt()
    end
  end
end
