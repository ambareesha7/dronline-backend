defmodule PatientProfilesManagement.FamilyRelationshipTest do
  use Postgres.DataCase, async: true

  alias PatientProfilesManagement.FamilyRelationship

  alias PatientProfilesManagement.Commands.RegisterFamilyRelationship

  describe "get_related_child_patient_ids/1" do
    test "returns list of child patient ids for given adult patient id" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 3}
      _ = FamilyRelationship.register_family_relationship(cmd)

      assert FamilyRelationship.get_related_child_patient_ids(1) == [2, 3]
    end

    test "returns empty list if patient doesn't have any associated child profiles" do
      assert FamilyRelationship.get_related_child_patient_ids(1) == []
    end

    test "doesn't return other patient children ids" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 3}
      _ = FamilyRelationship.register_family_relationship(cmd)

      assert FamilyRelationship.get_related_child_patient_ids(4) == []
    end
  end

  describe "who_should_be_notified/1" do
    test "returns given id if patient doesn't have any registered family relationship" do
      assert FamilyRelationship.who_should_be_notified(1) == 1
    end

    test "returns id of related adult patient when given id is registered as child patient" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      assert FamilyRelationship.who_should_be_notified(2) == 1
    end

    test "returns given id when it is registered as adult patient" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      assert FamilyRelationship.who_should_be_notified(1) == 1
    end
  end

  describe "get_related_adult_patient_id/1" do
    test "returns nil if patient doesn't have any registered family relationship" do
      assert FamilyRelationship.get_related_adult_patient_id(1) == nil
    end

    test "returns nil if patient is registered relationship as adult" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      assert FamilyRelationship.get_related_adult_patient_id(1) == nil
    end

    test "returns related adult patient id for child patient" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      assert FamilyRelationship.get_related_adult_patient_id(2) == 1
    end
  end

  describe "get_related_adult_patients_map/1" do
    test "returns child => adult relationship mapping" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      cmd = %RegisterFamilyRelationship{adult_patient_id: 3, child_patient_id: 4}
      _ = FamilyRelationship.register_family_relationship(cmd)

      assert FamilyRelationship.get_related_adult_patients_map([2, 4]) == %{2 => 1, 4 => 3}
    end

    test "doesn't return provided id in result map when relationship doesn't exist" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      result = FamilyRelationship.get_related_adult_patients_map([2, 4])

      assert result == %{2 => 1}
      refute Map.has_key?(result, 4)
    end

    test "doesn't return provided id in result map when it belongs to adult patient" do
      cmd = %RegisterFamilyRelationship{adult_patient_id: 1, child_patient_id: 2}
      _ = FamilyRelationship.register_family_relationship(cmd)

      cmd = %RegisterFamilyRelationship{adult_patient_id: 3, child_patient_id: 4}
      _ = FamilyRelationship.register_family_relationship(cmd)

      result = FamilyRelationship.get_related_adult_patients_map([2, 3])

      assert result == %{2 => 1}
      refute Map.has_key?(result, 3)
    end
  end
end
