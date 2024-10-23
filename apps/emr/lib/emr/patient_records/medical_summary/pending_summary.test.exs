defmodule EMR.PatientRecords.MedicalSummary.PendingSummaryTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.MedicalSummary.PendingSummary

  describe "create/2" do
    test "succeeds when pending summary entry doesn't exist yet" do
      assert {:ok, :created} = PendingSummary.create(1, 1, 1)
    end

    test "succeeds when pending summary entry already exists" do
      {:ok, :created} = PendingSummary.create(1, 1, 1)

      assert {:ok, :created} = PendingSummary.create(1, 1, 1)
    end
  end

  describe "resolve/2" do
    test "succeeds when pending summary entry exists" do
      {:ok, :created} = PendingSummary.create(1, 1, 1)

      assert :ok = PendingSummary.resolve(1, 1)
      refute Repo.one(PendingSummary)
    end

    test "succeeds when pending summary entry doesn't exist" do
      assert :ok = PendingSummary.resolve(1, 1)
      refute Repo.one(PendingSummary)
    end
  end

  describe "get_by_specialist_id/1" do
    test "returns single oldest entry if entries exist" do
      {:ok, :created} = PendingSummary.create(1, 1, 1)
      {:ok, :created} = PendingSummary.create(1, 2, 1)

      assert %PendingSummary{record_id: 1} = PendingSummary.get_by_specialist_id(1)
    end

    test "returns nil if no entry exists" do
      refute PendingSummary.get_by_specialist_id(1)
    end
  end
end
