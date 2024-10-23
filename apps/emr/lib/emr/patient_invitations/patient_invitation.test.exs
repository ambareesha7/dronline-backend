defmodule EMR.PatientInvitations.PatientInvitationTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientInvitations.PatientInvitation
  alias Postgres.Seeds.Country

  describe "create/2" do
    test "returns {:ok, invtitaion} when all params are valid" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      params = %{
        phone_number: "+48532568641"
      }

      assert {:ok, %PatientInvitation{}} = PatientInvitation.create(specialist.id, params)
    end

    test "returns {:error, changeset} when phone number is invalid" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      params = %{
        phone_number: "532568641"
      }

      assert {:error, %Ecto.Changeset{}} = PatientInvitation.create(specialist.id, params)
    end

    test "allows to invite by [phone_number], but stores invitation only once" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      params = %{
        phone_number: "+48532568641"
      }

      assert {:ok, %PatientInvitation{}} = PatientInvitation.create(specialist.id, params)
      assert {:ok, %PatientInvitation{}} = PatientInvitation.create(specialist.id, params)

      {:ok, _} = Postgres.Repo.fetch_one(PatientInvitation)
    end

    test "allows to invite by [email], but stores invitation only once" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      params = %{
        email: "patient_email@mail.com"
      }

      assert {:ok, %PatientInvitation{}} = PatientInvitation.create(specialist.id, params)
      assert {:ok, %PatientInvitation{}} = PatientInvitation.create(specialist.id, params)

      {:ok, _} = Postgres.Repo.fetch_one(PatientInvitation)
    end

    test "allows to invite by [email, phone_number], but stores invitation only once" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      params = %{
        email: "patient_email@mail.com",
        phone_number: "+48532568641"
      }

      assert {:ok, %PatientInvitation{}} = PatientInvitation.create(specialist.id, params)
      assert {:ok, %PatientInvitation{}} = PatientInvitation.create(specialist.id, params)

      {:ok, _} = Postgres.Repo.fetch_one(PatientInvitation)
    end

    test "{:error, changeset} if both email and phone_number empty" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      params = %{
        email: "",
        phone_number: nil
      }

      assert {:error, %Ecto.Changeset{}} = PatientInvitation.create(specialist.id, params)
    end

    test "ignores phone_number if it is equal to country dial_code" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      Country
      |> Repo.insert_all([
        %{
          id: "ua",
          name: "Ukraine",
          dial_code: "380"
        }
      ])

      params = %{
        email: "patient_email@mail.com",
        phone_number: "+380"
      }

      {:ok,
       %PatientInvitation{
         email: "patient_email@mail.com",
         phone_number: nil
       }} = PatientInvitation.create(specialist.id, params)
    end
  end

  describe "fetch_by_phone_number_or_email/2" do
    test "returns at most one for each specialist" do
      specialist_1 = Authentication.Factory.insert(:verified_specialist)
      specialist_2 = Authentication.Factory.insert(:verified_specialist)

      _patient_invitation =
        EMR.Factory.insert(:patient_invitation,
          specialist_id: specialist_1.id,
          phone_number: "+111111",
          email: "same@com"
        )

      _patient_invitation =
        EMR.Factory.insert(:patient_invitation,
          specialist_id: specialist_1.id,
          phone_number: "+222222",
          email: "same@com"
        )

      _patient_invitation =
        EMR.Factory.insert(:patient_invitation,
          specialist_id: specialist_2.id,
          phone_number: "+333333",
          email: "same@com"
        )

      assert [
               %PatientInvitation{
                 phone_number: "+111111"
               },
               %PatientInvitation{
                 phone_number: "+333333"
               }
             ] = PatientInvitation.fetch_by_phone_number_or_email(nil, "same@com")
    end
  end
end
