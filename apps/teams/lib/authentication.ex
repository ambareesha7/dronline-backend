defmodule Teams.Authentication do
  alias Postgres.Repo

  alias Teams.Authentication.Credentials

  def register_team_manager(team_id, identifier, password) do
    %Credentials{}
    |> Credentials.changeset(%{team_id: team_id, identifier: identifier, password: password})
    |> Repo.insert!()

    :ok
  end

  def team_id(identifier, password) do
    with {:ok, credentials} <- fetch_credentials(identifier),
         :ok <- verify_password(credentials, password) do
      {:ok, credentials.team_id}
    else
      _ ->
        {:error, :incorrect_credentials}
    end
  end

  defp fetch_credentials(identifier) do
    if credentials = Repo.get_by(Credentials, identifier: identifier) do
      {:ok, credentials}
    else
      {:error, :not_found}
    end
  end

  defp verify_password(credentials, password) do
    case Pbkdf2.verify_pass(credentials, password) do
      {:ok, _} -> :ok
      {:error, _} -> {:error, :invalid_credentials}
    end
  end
end
