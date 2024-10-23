defmodule MembershipMock.EndTrialsTest do
  use Postgres.DataCase, async: true

  alias MembershipMock.EndTrials
  alias MembershipMock.EndTrials.Specialist
  alias MembershipMock.Subscription

  describe "end_trials/0" do
    test "downgrades package_type to BASIC if trial ended" do
      specialist_1 =
        %Specialist{}
        |> change(%{
          email: "any1@com",
          auth_token: "any1"
        })
        |> Repo.insert!()

      specialist_2 =
        %Specialist{}
        |> change(%{
          email: "any2@com",
          auth_token: "any2",
          trial_ends_at: ~N[2020-01-01 02:00:00]
        })
        |> Repo.insert!()

      %Subscription{}
      |> change(
        type: "PLATINUM",
        specialist_id: specialist_2.id
      )
      |> Repo.insert!()

      EndTrials.end_trials()

      assert %Specialist{
               package_type: "PLATINUM"
             } = Repo.get_by!(Specialist, id: specialist_1.id)

      assert %Specialist{
               package_type: "BASIC"
             } = Repo.get_by!(Specialist, id: specialist_2.id)

      refute Repo.get_by(Subscription, specialist_id: specialist_2.id)
    end
  end
end
