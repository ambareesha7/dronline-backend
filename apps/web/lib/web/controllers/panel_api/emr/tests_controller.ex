defmodule Web.PanelApi.EMR.TestsController do
  use Conductor
  use Web, :controller

  alias EMR.Tests

  action_fallback Web.FallbackController

  @authorize scopes: [
               "GP",
               "NURSE",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def index(conn, params) do
    specialist_id = conn.assigns.current_specialist_id
    params = Tests.decode_next_token(params)

    with {:ok, tests_bundles, next_token} <- Tests.get_for_specialist(specialist_id, params) do
      specialists_generic_data =
        tests_bundles
        |> Enum.map(& &1.specialist_id)
        |> Enum.uniq()
        |> Web.SpecialistGenericData.get_by_ids()

      patients_generic_data =
        tests_bundles
        |> Enum.map(& &1.patient_id)
        |> Enum.uniq()
        |> Web.PatientGenericData.get_by_ids()

      render(conn, "index.proto", %{
        tests_bundles: tests_bundles,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      })
    end
  end
end

defmodule Web.PanelApi.EMR.TestsView do
  use Web, :view

  alias EMR.Tests

  def render("index.proto", %{
        tests_bundles: tests_bundles,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      }) do
    %Proto.EMR.GetTestsResponse{
      bundles: Enum.map(tests_bundles, &render_tests_bundle/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1),
      next_token: Tests.encode_next_token(next_token)
    }
  end

  defp render_tests_bundle(tests_bundle) do
    %Proto.EMR.TestsBundle{
      specialist_id: tests_bundle.specialist_id,
      patient_id: tests_bundle.patient_id,
      inserted_at: tests_bundle.inserted_at |> Timex.to_unix(),
      tests:
        Enum.map(tests_bundle.tests, fn test ->
          %Proto.EMR.Test{
            name: test.medical_test.name,
            category_name: test.medical_test.medical_tests_category.name,
            description: test.description
          }
        end)
    }
  end
end
