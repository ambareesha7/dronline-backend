defmodule Admin.InternalSpecialists.InviteToTeam do
  alias Admin.InternalSpecialists.InternalSpecialist

  @spec call(map) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def call(params) do
    parsed_params = parse_params(params)

    with {:ok, specialist} <- InternalSpecialist.create(parsed_params),
         {:ok, specialist} <- InternalSpecialist.create_password_recovery_token(specialist) do
      {:ok, _job} =
        %{
          type: "INTERNAL_SPECIALIST_ADDED_TO_TEAM",
          specialist_email: specialist.email,
          password_recovery_token: specialist.password_recovery_token
        }
        |> Mailers.MailerJobs.new()
        |> Oban.insert()

      {:ok, parse_result(specialist)}
    end
  end

  defp parse_params(params) do
    %{
      email: params.email,
      type: parse_type_param(params.type)
    }
  end

  defp parse_type_param(type) do
    type
    |> case do
      :UNKNOWN_TYPE -> nil
      key -> key |> to_string()
    end
  end

  defp parse_result(result) do
    %{
      email: result.email,
      type: result.type |> String.to_existing_atom()
    }
  end
end
