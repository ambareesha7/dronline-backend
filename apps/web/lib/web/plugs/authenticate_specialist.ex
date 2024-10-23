defmodule Web.Plugs.AuthenticateSpecialist do
  use Web, :plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    token = conn |> get_req_header("x-auth-token") |> List.first()

    case token && Authentication.authenticate_specialist(token) do
      {:ok, specialist_data} ->
        conn
        |> assign(:current_specialist_id, specialist_data.id)
        |> assign_scopes(specialist_data)

      _ ->
        conn
        |> send_resp(401, "")
        |> halt()
    end
  end

  defp assign_scopes(conn, %{type: "EXTERNAL", approval_status: status} = specialist_data)
       when status in ["REJECTED"],
       do: assign(conn, :scopes, ["EXTERNAL_REJECTED", specialist_data.package_type])

  defp assign_scopes(conn, %{onboarding_completed_at: nil, type: type} = specialist_data)
       when type in ["NURSE", "GP"],
       do:
         assign(conn, :scopes, [
           specialist_data.type <> "_ONBOARDING",
           specialist_data.package_type
         ])

  defp assign_scopes(conn, specialist_data),
    do: assign(conn, :scopes, [specialist_data.type, specialist_data.package_type])
end
