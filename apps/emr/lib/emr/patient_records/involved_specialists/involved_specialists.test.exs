defmodule EMR.PatientRecords.InvolvedSpecialistsTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.InvolvedSpecialists

  describe "register_involvement/3" do
    test "creates new db entry if specialist wasn't involved yet with given record" do
      patient_id = 1
      record_id = 2
      specialist_id = 3

      :ok = InvolvedSpecialists.register_involvement(patient_id, record_id, specialist_id)
      entry = Repo.get_by(InvolvedSpecialists, patient_id: patient_id, record_id: record_id)

      assert entry.patient_id == patient_id
      assert entry.record_id == record_id
      assert entry.involved_specialist_id == specialist_id
    end

    test "doesn't do anything if specialist was already involved with given record" do
      patient_id = 1
      record_id = 2
      specialist_id = 3

      :ok = InvolvedSpecialists.register_involvement(patient_id, record_id, specialist_id)
      entries = Repo.all(InvolvedSpecialists)
      assert length(entries) == 1

      :ok = InvolvedSpecialists.register_involvement(patient_id, record_id, specialist_id)
      entries = Repo.all(InvolvedSpecialists)
      assert length(entries) == 1
    end
  end

  describe "get_for_record/2" do
    test "returns list of ids of specialists involved with given record" do
      patient_id = 1
      record_id = 2
      specialist1_id = 3
      specialist2_id = 4

      :ok = InvolvedSpecialists.register_involvement(patient_id, record_id, specialist1_id)
      :ok = InvolvedSpecialists.register_involvement(patient_id, record_id, specialist2_id)

      specialist_ids = InvolvedSpecialists.get_for_record(patient_id, record_id)

      assert specialist1_id in specialist_ids
      assert specialist2_id in specialist_ids
    end

    test "doesn't return ids of specialists not involved with given record" do
      patient_id = 1
      record1_id = 2
      record2_id = 3
      specialist1_id = 4
      specialist2_id = 5
      specialist3_id = 6

      :ok = InvolvedSpecialists.register_involvement(patient_id, record1_id, specialist1_id)
      :ok = InvolvedSpecialists.register_involvement(patient_id, record1_id, specialist2_id)
      :ok = InvolvedSpecialists.register_involvement(patient_id, record2_id, specialist2_id)
      :ok = InvolvedSpecialists.register_involvement(patient_id, record2_id, specialist3_id)

      record1_specialist_ids = InvolvedSpecialists.get_for_record(patient_id, record1_id)
      record2_specialist_ids = InvolvedSpecialists.get_for_record(patient_id, record2_id)

      refute specialist1_id in record2_specialist_ids
      refute specialist3_id in record1_specialist_ids
    end
  end
end
