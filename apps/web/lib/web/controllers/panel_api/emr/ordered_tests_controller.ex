defmodule Web.PanelApi.EMR.OrderedTestsController do
  use Web, :controller

  plug Web.Plugs.RequireOnboarding

  action_fallback Web.FallbackController

  @decode Proto.EMR.CreateOrderedTestsRequest
  def create(conn, params) do
    patient_id = String.to_integer(params["patient_id"])
    record_id = String.to_integer(params["record_id"])

    specialist_id = conn.assigns.current_specialist_id

    with {:ok, bundle} <-
           EMR.create_ordered_tests_bundle(
             patient_id,
             record_id,
             specialist_id,
             conn.assigns.protobuf
           ) do
      specialists_generic_data = Web.SpecialistGenericData.get_by_ids([bundle.specialist_id])

      _ =
        NotificationsWrite.notify_patient_about_record_change(
          record_id,
          patient_id,
          specialist_id,
          tests_bundle_id: bundle.id
        )

      conn
      |> render("create.proto", %{
        ordered_tests_bundle: bundle,
        specialists_generic_data: specialists_generic_data
      })
    end
  end

  def history_for_record(conn, params) do
    record_id = String.to_integer(params["record_id"])
    {:ok, ordered_tests_history} = EMR.fetch_ordered_tests_history_for_record(record_id)

    conn
    |> render("history.proto", %{
      ordered_tests_history: ordered_tests_history
    })
  end
end

defmodule Web.PanelApi.EMR.OrderedTestsView do
  use Web, :view

  def render("create.proto", %{
        ordered_tests_bundle: ordered_tests_bundle,
        specialists_generic_data: specialists_generic_data
      }) do
    %Proto.EMR.CreateOrderedTestsResponse{
      items: Web.View.EMR.render_ordered_tests(ordered_tests_bundle),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("history.proto", %{
        ordered_tests_history: ordered_tests_history
      }) do
    %Proto.EMR.GetOrderedTestsHistoryResponse{
      bundles: Enum.map(ordered_tests_history, &Web.View.EMR.render_ordered_tests_bundle/1)
    }
  end
end
