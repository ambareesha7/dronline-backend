defmodule Postgres.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Postgres.DataCase

      alias Postgres.Repo

      defp unique_string, do: System.unique_integer() |> to_string()
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Postgres.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Postgres.Repo, {:shared, self()})
    end

    :ok
  end

  setup do
    Enum.each([:proto], &Application.ensure_all_started/1)
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_patient(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
