defmodule Admin.InternalSpecialists.CreateTest do
  use Postgres.DataCase, async: true

  alias Admin.InternalSpecialists.Create
  alias Admin.InternalSpecialists.InternalSpecialist

  describe "call/1" do
    test "succeeds when params are valid" do
      params = %{
        email: "nurse@example.com",
        type: :NURSE |> Proto.AdminPanel.InternalSpecialistAccount.Type.value()
      }

      assert {:ok, _internal_specialist} = Create.call(params)
      {:ok, internal_specialist} = Postgres.Repo.fetch_one(InternalSpecialist)
      refute is_nil(internal_specialist.password_recovery_token)
    end
  end
end
