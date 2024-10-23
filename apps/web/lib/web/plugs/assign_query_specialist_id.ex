defmodule Web.Plugs.AssignQuerySpecialistId do
  use Web, :plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    current_specialist_id = conn.assigns.current_specialist_id

    team_member_id =
      case conn.params["specialist_id"] do
        nil -> nil
        specialist_id when is_integer(specialist_id) -> specialist_id
        specialist_id -> String.to_integer(specialist_id)
      end

    current_specialist_id
    |> team_member_or_current_specialist_id(team_member_id)
    |> case do
      :unauthorized ->
        conn
        |> send_resp(401, "")
        |> halt()

      specialist_id ->
        conn
        |> assign(:query_specialist_id, specialist_id)
    end
  end

  defp team_member_or_current_specialist_id(current_specialist_id, nil), do: current_specialist_id

  defp team_member_or_current_specialist_id(current_specialist_id, other_specialist_id) do
    if team_member?(current_specialist_id, other_specialist_id),
      do: other_specialist_id,
      else: :unauthorized
  end

  defp team_member?(current_specialist_id, other_specialist_id) do
    current_team_id = Teams.specialist_team_id(current_specialist_id)
    other_team_id = Teams.specialist_team_id(other_specialist_id)

    current_team_id && current_team_id == other_team_id
  end
end
