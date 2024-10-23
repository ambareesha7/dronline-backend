defmodule Visits.DemandsTest do
  use Postgres.DataCase, async: true

  alias Visits.Demands, as: VD

  describe "create/1" do
    test "creates new visit demand for patient and medical category" do
      params = %{patient_id: 1, medical_category_id: 1}

      {:ok, visit_demand} = VD.create(params)
      {:ok, [fetched_visit_demand]} = VD.fetch_patient_visit_demands(params.patient_id)

      assert fetched_visit_demand == visit_demand
    end

    test "doesn't duplicate record for medical category" do
      params = %{patient_id: 1, medical_category_id: 1}
      {:ok, _visit_demand} = VD.create(params)
      {:ok, _visit_demand} = VD.create(params)

      {:ok, visit_demands} = VD.fetch_visit_demands_for_categories([params.medical_category_id])
      assert length(visit_demands) == 1
    end

    test "creates new visit demand for patient and specialist" do
      params = %{patient_id: 1, specialist_id: 1}

      {:ok, visit_demand} = VD.create(params)
      {:ok, [fetched_visit_demand]} = VD.fetch_patient_visit_demands(params.patient_id)

      assert fetched_visit_demand == visit_demand
    end

    test "doesn't duplicate record for specialist" do
      params = %{patient_id: 1, specialist_id: 1}
      {:ok, _visit_demand} = VD.create(params)
      {:ok, _visit_demand} = VD.create(params)

      {:ok, visit_demands} = VD.fetch_visit_demands_for_specialist(params.specialist_id)
      assert length(visit_demands) == 1
    end
  end

  describe "fetch_patient_visit_demands/1" do
    test "returns list of visit demands for patient" do
      params = %{patient_id: 1, medical_category_id: 1}
      {:ok, visit_demand} = VD.create(params)

      {:ok, [fetched_visit_demand]} = VD.fetch_patient_visit_demands(params.patient_id)
      assert fetched_visit_demand == visit_demand
    end

    test "returns empty list if no results are found" do
      assert {:ok, []} = VD.fetch_patient_visit_demands(1)
    end
  end

  describe "fetch_visit_demands_for_categories/2" do
    test "returns all visit demands for given list of categories" do
      {:ok, _visit_demand} = VD.create(%{patient_id: 1, medical_category_id: 1})
      {:ok, _visit_demand} = VD.create(%{patient_id: 2, medical_category_id: 2})

      {:ok, visit_demands} = VD.fetch_visit_demands_for_categories([1, 2])
      assert length(visit_demands) == 2
    end

    test "returns empty list if there are no visit demands for provided categories" do
      assert {:ok, []} = VD.fetch_visit_demands_for_categories([1])
    end
  end

  describe "fetch_visit_demands_for_specialist/2" do
    test "returns all visit demands for given specialist" do
      {:ok, _visit_demand} = VD.create(%{patient_id: 1, specialist_id: 1})
      {:ok, _visit_demand} = VD.create(%{patient_id: 2, specialist_id: 1})

      {:ok, visit_demands} = VD.fetch_visit_demands_for_specialist(1)
      assert length(visit_demands) == 2
    end

    test "returns empty list if there are no visit demands for provided categories" do
      assert {:ok, []} = VD.fetch_visit_demands_for_specialist(1)
    end
  end

  describe "delete_by_ids/1" do
    test "deletes all visit demands by ids" do
      {:ok, visit_demand1} = VD.create(%{patient_id: 1, medical_category_id: 1})
      {:ok, visit_demand2} = VD.create(%{patient_id: 2, medical_category_id: 1})

      :ok = VD.delete_by_ids([visit_demand1.id, visit_demand2.id])
      assert {:ok, []} = VD.fetch_visit_demands_for_categories([1])
    end
  end
end
