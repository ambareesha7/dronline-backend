defmodule Admin.Newsletter.SubscriberTest do
  use Postgres.DataCase, async: true

  alias Admin.Newsletter.Subscriber

  describe "subscribe/2" do
    test "create subscriber when params are valid" do
      assert {:ok, subscriber} = Subscriber.create("office@appunite.com", "+48532568641")

      assert {:ok, fetched_subscriber} = Postgres.Repo.fetch_one(Subscriber)

      assert fetched_subscriber.id == subscriber.id
      assert fetched_subscriber.email == subscriber.email
      assert fetched_subscriber.phone_number == subscriber.phone_number
    end

    test "returns {:error, %Ecto.Changeset{}} when params are not valid" do
      assert {:error, %Ecto.Changeset{}} =
               Subscriber.create("office@appunite.com", "|48532568641")
    end

    test "returns {:error, %Ecto.Changeset{}} when email is duplicated" do
      assert {:ok, _subscriber} = Subscriber.create("office@appunite.com", "+48532568641")

      assert {:error, %Ecto.Changeset{}} =
               Subscriber.create("office@appunite.com", "+48532568641")
    end
  end
end
