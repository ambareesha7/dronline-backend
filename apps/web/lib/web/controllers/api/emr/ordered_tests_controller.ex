defmodule Web.Api.EMR.OrderedTestsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def history_for_record(conn, params) do
    record_id = String.to_integer(params["record_id"])
    {:ok, bundles} = EMR.fetch_ordered_tests_history_for_record(record_id)

    conn
    |> render("history.proto", %{
      bundles: bundles
    })
  end

  def show(conn, params) do
    # TODO: check if the record is for current patient
    bundle_id = String.to_integer(params["id"])

    with {:ok, bundle} <- EMR.fetch_ordered_tests_bundle(bundle_id),
         specialist_generic_data <- Web.SpecialistGenericData.get_by_id(bundle.specialist_id) do
      render(conn, "show.proto", %{bundle: bundle, specialist: specialist_generic_data})
    end
  end
end

defmodule Web.Api.EMR.OrderedTestsView do
  use Web, :view

  def render("history.proto", %{
        bundles: bundles
      }) do
    %Proto.EMR.GetOrderedTestsHistoryResponse{
      bundles: Enum.map(bundles, &Web.View.EMR.render_ordered_tests_bundle/1)
    }
  end

  def render("show.proto", %{bundle: bundle, specialist: specialist}) do
    %{
      bundle: Web.View.EMR.render_ordered_tests_bundle(bundle),
      specialist: Web.View.Generics.render_specialist(specialist)
    }
    |> Proto.validate!(Proto.EMR.GetTestResponse)
    |> Proto.EMR.GetTestResponse.new()
  end
end
