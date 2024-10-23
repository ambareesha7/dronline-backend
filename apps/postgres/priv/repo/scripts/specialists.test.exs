Code.require_file(Path.join(:code.priv_dir(:postgres), "repo/scripts/specialists.exs"))

ExUnit.start()

defmodule Postgres.Scripts.OnboardedSpecialistsTest do
  use ExUnit.Case

  describe "non_rejected" do
    setup do
      on_exit(fn ->
        Postgres.Repo.delete_all(Authentication.Specialist)
      end)
    end

    test "gets only specialists from this year who are not rejected" do
      naive_now = NaiveDateTime.utc_now()
      last_year = Timex.shift(naive_now, years: -1)

      specialist =
        Authentication.Factory.insert(:verified_specialist,
          email: "krypto@example.com"
        )

      {:ok, specialist} =
        specialist
        |> Ecto.Changeset.change(%{onboarding_completed_at: naive_now})
        |> Postgres.Repo.update()

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "krypto",
          last_name: "dog"
        )

      specialist_last_year =
        Authentication.Factory.insert(:verified_specialist, email: "krypto_last_year@example.com")

      {:ok, specialist_last_year} =
        specialist_last_year
        |> Ecto.Changeset.change(%{onboarding_completed_at: last_year})
        |> Postgres.Repo.update()

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist_last_year.id,
          first_name: "krypto_last_year",
          last_name: "dog_last_year"
        )

      specialist_this_year_rejected = Authentication.Factory.insert(:verified_specialist)

      {:ok, specialist_this_year_rejected} =
        specialist_this_year_rejected
        |> Ecto.Changeset.change(%{
          onboarding_completed_at: naive_now,
          approval_status: "REJECTED"
        })
        |> Postgres.Repo.update()

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist_this_year_rejected.id
        )

      assert [
               %{
                 email: "krypto@example.com",
                 first_name: "krypto",
                 last_name: "dog"
               },
               %{
                 email: "krypto_last_year@example.com",
                 first_name: "krypto_last_year",
                 last_name: "dog_last_year"
               }
             ] == Postgres.Scripts.Specialists.non_rejected() |> Enum.sort_by(& &1.email)
    end
  end
end
