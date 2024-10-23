defmodule Proto.MedicalLibrariesView do
  use Proto.View

  def render("condition.proto", %{condition: condition}) do
    %{
      id: condition.id,
      name: condition.name
    }
    |> Proto.validate!(Proto.EMR.MedicalCondition)
    |> Proto.EMR.MedicalCondition.new()
  end

  def render("procedure.proto", %{procedure: procedure}) do
    %{
      id: procedure.id,
      name: procedure.name
    }
    |> Proto.validate!(Proto.EMR.MedicalProcedure)
    |> Proto.EMR.MedicalProcedure.new()
  end

  def render("medication.proto", %{medication: medication}) do
    %{
      id: medication.id,
      name: medication.name
    }
    |> Proto.validate!(Proto.EMR.MedicalMedication)
    |> Proto.EMR.MedicalMedication.new()
  end

  def render("tests_by_category.proto", %{category: category}) do
    %{
      id: category.id,
      name: category.name,
      tests:
        render_many(
          category.tests,
          __MODULE__,
          "test.proto",
          as: :test
        )
    }
    |> Proto.validate!(Proto.EMR.MedicalTestsCategory)
    |> Proto.EMR.MedicalTestsCategory.new()
  end

  def render("test.proto", %{test: test}) do
    %{
      id: test.id,
      name: test.name
    }
    |> Proto.validate!(Proto.EMR.MedicalTest)
    |> Proto.EMR.MedicalTest.new()
  end
end
