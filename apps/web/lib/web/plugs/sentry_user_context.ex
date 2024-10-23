defmodule Web.Plugs.SentryUserContext do
  use Web, :plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%{assigns: %{current_patient_id: current_patient_id}} = conn, _opts) do
    Sentry.Context.set_user_context(%{"id" => "PATIENT #{current_patient_id}"})

    conn
  end

  @impl Plug
  def call(%{assigns: %{current_specialist_id: current_specialist_id}} = conn, _opts) do
    Sentry.Context.set_user_context(%{"id" => "SPECIALIST #{current_specialist_id}"})

    conn
  end

  @impl Plug
  def call(%{assigns: %{current_admin_id: current_admin_id}} = conn, _opts) do
    Sentry.Context.set_user_context(%{"id" => "ADMIN #{current_admin_id}"})

    conn
  end

  @impl Plug
  def call(conn, _opts) do
    Sentry.Context.set_user_context(%{"ip_address" => get_ip(conn)})

    conn
  end

  defp get_ip(conn) do
    conn |> get_req_header("x-forwarded-for") |> List.first()
  end
end
