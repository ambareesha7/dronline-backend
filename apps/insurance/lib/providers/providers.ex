defmodule Insurance.Providers do
  use Postgres.Service

  alias Insurance.Providers.Provider

  def all_for_country(country) do
    providers =
      Provider
      |> join(:inner, [p], c in assoc(p, :country))
      |> where([_, c], c.id == ^country)
      |> Repo.all()

    {:ok, providers}
  end
end
