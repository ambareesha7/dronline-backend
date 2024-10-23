defmodule Authentication.Specialist.PasswordChange.Confirm do
  alias Authentication.Specialist
  alias Authentication.Specialist.PasswordChange

  def call(confirmation_token) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:fetch_password_change, &fetch_password_change(&1, &2, confirmation_token))
    |> Ecto.Multi.run(:update_password_hash, &update_password_hash/2)
    |> Ecto.Multi.delete(:delete_password_change, & &1.fetch_password_change)
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, _} ->
        :ok

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp fetch_password_change(_repo, _multi, confirmation_token) do
    PasswordChange.fetch_by_confirmation_token(confirmation_token)
  end

  defp update_password_hash(_repo, %{fetch_password_change: password_change}) do
    %{specialist_id: specialist_id, password_hash: password_hash} = password_change

    Specialist.update_password_hash(specialist_id, password_hash)
  end
end
