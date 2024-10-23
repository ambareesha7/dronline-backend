defmodule Membership.Specialists.Package do
  use Postgres.Service

  @spec fetch_active_type(pos_integer) :: {:ok, String.t()}
  def fetch_active_type(id) do
    {:ok, specialist} =
      Membership.Specialists.Specialist
      |> where(id: ^id)
      |> select([:package_type])
      |> Repo.fetch_one()

    {:ok, specialist.package_type}
  end
end
