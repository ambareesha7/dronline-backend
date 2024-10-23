defmodule MembershipMock.EndTrials do
  use Postgres.Service

  alias MembershipMock.EndTrials.Specialist
  alias MembershipMock.Subscription

  def end_trials do
    {_, rows} =
      Specialist
      |> where([s], fragment("? < NOW()", s.trial_ends_at))
      |> select([s], s.id)
      |> Repo.update_all(set: [package_type: "BASIC"])

    ids = rows || []

    Subscription
    |> where([s], s.specialist_id in ^ids)
    |> Repo.delete_all()
  end
end
