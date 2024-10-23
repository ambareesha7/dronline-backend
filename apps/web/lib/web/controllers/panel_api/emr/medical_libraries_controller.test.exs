defmodule Web.PanelApi.EMR.MedicalLibrariesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetMedicalConditionsResponse
  alias Proto.EMR.GetMedicalMedicationsResponse
  alias Proto.EMR.GetMedicalProceduresResponse
  alias Proto.EMR.GetMedicalTestsByCategoriesResponse

  describe "GET index" do
    setup [:authenticate_nurse]

    test "get conditions succeeds", %{conn: conn} do
      [
        %{id: "1111", name: "aaaa"},
        %{id: "2222", name: "aabb"},
        %{id: "3333", name: "bbbb"},
        %{id: "3344", name: "bbcc"}
      ]
      |> Enum.each(fn condition ->
        EMR.Factory.insert(:condition, condition)
      end)

      path = panel_emr_medical_libraries_path(conn, :conditions)
      conn = get(conn, path, filter: "aa")

      assert response(conn, 200)

      %GetMedicalConditionsResponse{
        conditions: [
          condition1,
          condition2
        ]
      } = proto_response(conn, 200, GetMedicalConditionsResponse)

      assert condition1.name == "aaaa"
      assert condition2.name == "aabb"
    end

    test "get procedures succeeds", %{conn: conn} do
      [
        %{id: "1111", name: "aaaa"},
        %{id: "2222", name: "aabb"},
        %{id: "3333", name: "bbbb"},
        %{id: "3344", name: "bbcc"}
      ]
      |> Enum.each(fn plan ->
        EMR.Factory.insert(:procedure, plan)
      end)

      path = panel_emr_medical_libraries_path(conn, :procedures)
      conn = get(conn, path, filter: "33")

      assert response(conn, 200)

      %GetMedicalProceduresResponse{
        procedures: [
          plan1,
          plan2
        ]
      } = proto_response(conn, 200, GetMedicalProceduresResponse)

      assert plan1.name == "bbbb"
      assert plan2.name == "bbcc"
    end

    test "get tests_by_categories succeeds", %{conn: conn} do
      [
        %{id: 1, name: "category_1"},
        %{id: 2, name: "category_2"}
      ]
      |> Enum.each(fn plan ->
        EMR.Factory.insert(:tests_category, plan)
      end)

      [
        %{
          id: 1,
          category_id: 1,
          name: "test_1"
        },
        %{
          id: 2,
          category_id: 1,
          name: "test_2"
        },
        %{
          id: 3,
          category_id: 2,
          name: "test_3"
        }
      ]
      |> Enum.each(fn test ->
        EMR.Factory.insert(:test, test)
      end)

      path = panel_emr_medical_libraries_path(conn, :tests_by_categories)
      conn = get(conn, path)

      %{
        categories: [
          %Proto.EMR.MedicalTestsCategory{
            id: 1,
            tests: [
              %Proto.EMR.MedicalTest{
                id: _test_id_1
              },
              %Proto.EMR.MedicalTest{
                id: _test_id_2
              }
            ]
          },
          %Proto.EMR.MedicalTestsCategory{
            id: 2,
            tests: [
              %Proto.EMR.MedicalTest{
                id: test_id_3
              }
            ]
          }
        ]
      } = proto_response(conn, 200, GetMedicalTestsByCategoriesResponse)

      assert test_id_3 == 3
    end

    test "get medications succeeds", %{conn: conn} do
      [
        %{name: "aaaa"},
        %{name: "aabb"},
        %{name: "bbbb"},
        %{name: "bbcc"}
      ]
      |> Enum.each(fn medication ->
        EMR.Factory.insert(:medication, medication)
      end)

      path = panel_emr_medical_libraries_path(conn, :medications)
      conn = get(conn, path, filter: "aa")

      assert response(conn, 200)

      %GetMedicalMedicationsResponse{
        medications: [
          medication1,
          medication2
        ]
      } = proto_response(conn, 200, GetMedicalMedicationsResponse)

      assert medication1.name == "aaaa"
      assert medication2.name == "aabb"
    end
  end
end
