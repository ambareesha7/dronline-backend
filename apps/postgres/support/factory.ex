defmodule Postgres.Factory do
  alias Postgres.Repo
  alias Postgres.Seeds.Country

  defp country_default_params do
    %{
      id: "us",
      name: "USA",
      dial_code: "1"
    }
  end

  def insert(:country, params) do
    params = Map.merge(country_default_params(), Enum.into(params, %{}))

    %Country{}
    |> Ecto.Changeset.cast(params, [:id, :name, :dial_code])
    |> Repo.insert!()
  end
end
