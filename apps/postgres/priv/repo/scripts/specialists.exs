defmodule Postgres.Scripts.Specialists do
  import Ecto.Query

  def non_rejected do
    Authentication.Specialist
    |> join(:inner, [s], bi in SpecialistProfile.BasicInfo, on: s.id == bi.specialist_id)
    |> where([s], s.approval_status != "REJECTED")
    |> select([s, bi], %{first_name: bi.first_name, last_name: bi.last_name, email: s.email})
    |> Postgres.Repo.all()
  end
end
