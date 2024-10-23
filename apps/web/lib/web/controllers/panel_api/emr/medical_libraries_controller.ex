defmodule Web.PanelApi.EMR.MedicalLibrariesController do
  use Web, :controller

  action_fallback Web.FallbackController

  def conditions(conn, %{"filter" => filter}) do
    with conditions <- EMR.fetch_conditions(filter) do
      render(conn, "conditions.proto", %{conditions: conditions})
    end
  end

  def procedures(conn, %{"filter" => filter}) do
    with procedures <- EMR.fetch_procedures(filter) do
      render(conn, "procedures.proto", %{procedures: procedures})
    end
  end

  def medications(conn, %{"filter" => filter}) do
    with medications <- EMR.fetch_medications(filter) do
      render(conn, "medications.proto", %{medications: medications})
    end
  end

  def tests_by_categories(conn, _params) do
    with tests_by_categories <- EMR.fetch_tests_by_categories() do
      render(conn, "tests_by_categories.proto", %{tests_by_categories: tests_by_categories})
    end
  end
end

defmodule Web.PanelApi.EMR.MedicalLibrariesView do
  use Web, :view

  def render("conditions.proto", %{conditions: conditions}) do
    Proto.EMR.GetMedicalConditionsResponse.new(%{
      conditions:
        render_many(
          conditions,
          Proto.MedicalLibrariesView,
          "condition.proto",
          as: :condition
        )
    })
  end

  def render("procedures.proto", %{procedures: procedures}) do
    Proto.EMR.GetMedicalProceduresResponse.new(%{
      procedures:
        render_many(
          procedures,
          Proto.MedicalLibrariesView,
          "procedure.proto",
          as: :procedure
        )
    })
  end

  def render("medications.proto", %{medications: medications}) do
    Proto.EMR.GetMedicalMedicationsResponse.new(%{
      medications:
        render_many(
          medications,
          Proto.MedicalLibrariesView,
          "medication.proto",
          as: :medication
        )
    })
  end

  def render("tests_by_categories.proto", %{tests_by_categories: tests_by_categories}) do
    Proto.EMR.GetMedicalTestsByCategoriesResponse.new(%{
      categories:
        render_many(
          tests_by_categories,
          Proto.MedicalLibrariesView,
          "tests_by_category.proto",
          as: :category
        )
    })
  end
end
