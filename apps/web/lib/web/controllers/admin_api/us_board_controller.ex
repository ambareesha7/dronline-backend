defmodule Web.AdminApi.USBoardController do
  use Web, :controller

  action_fallback Web.FallbackController

  def fetch_requests(conn, _params) do
    requests = Admin.USBoard.fetch_all_second_opinions_requests()

    specialists_history =
      requests
      |> Enum.map(& &1.id)
      |> Admin.USBoard.fetch_specialists_history_for_requests()

    {:ok, specialists_basic_infos} =
      specialists_history
      |> Map.values()
      |> List.flatten()
      |> Enum.map(& &1.specialist_id)
      |> SpecialistProfile.fetch_basic_infos()

    render(conn, "fetch_requests.proto", %{
      requests: requests,
      specialists_history: specialists_history,
      specialists_basic_infos: specialists_basic_infos
    })
  end

  def fetch_request(conn, %{"request_id" => request_id}) do
    request = Admin.USBoard.fetch_second_opinion_request(request_id)

    specialists_history =
      [request_id]
      |> Admin.USBoard.fetch_specialists_history_for_requests()
      |> Map.get(request_id, [])

    {:ok, specialists_basic_infos} =
      specialists_history
      |> Enum.map(& &1.specialist_id)
      |> SpecialistProfile.fetch_basic_infos()

    render(conn, "fetch_request.proto", %{
      request: request,
      specialists_history: specialists_history,
      specialists_basic_infos: specialists_basic_infos
    })
  end

  def fetch_us_board_specialists(conn, _params) do
    specialists = Admin.USBoard.fetch_all_us_board_specialists()

    render(conn, "us_board_specialists.proto", %{specialists: specialists})
  end

  @decode Proto.AdminPanel.USBoardAssignSpecialistRequest
  def assign_specialist(
        %{
          assigns: %{
            protobuf: %{
              specialist_id: specialist_id,
              request_id: request_id
            }
          }
        } = conn,
        _params
      ) do
    with {:ok, _assigned_specialist} <-
           Visits.assign_specialist_to_second_opinion_request(specialist_id, request_id) do
      resp(conn, 201, "")
    end
  end
end

defmodule Web.AdminApi.USBoardView do
  use Web, :view

  def render("fetch_requests.proto", %{
        requests: requests,
        specialists_history: specialists_history,
        specialists_basic_infos: specialists_basic_infos
      }) do
    requests_with_specialists_history =
      Enum.map(requests, fn request ->
        history_with_specialists_info =
          specialists_history
          |> Map.get(request.id, [])
          |> add_specialist_info_to_history(specialists_basic_infos)

        Map.put(request, :specialists_history, history_with_specialists_info)
      end)

    %Proto.Visits.USBoardSecondOpinionRequestsResponse{
      us_board_second_opinion_requests:
        Enum.map(
          requests_with_specialists_history,
          &Web.View.Visits.render_us_board_second_opinion_request/1
        )
    }
  end

  def render("fetch_request.proto", %{
        request: request,
        specialists_history: specialists_history,
        specialists_basic_infos: specialists_basic_infos
      }) do
    history_with_specialists_info =
      add_specialist_info_to_history(specialists_history, specialists_basic_infos)

    requests_with_specialists_history =
      Map.put(request, :specialists_history, history_with_specialists_info)

    %Proto.Visits.USBoardSecondOpinionRequestResponse{
      us_board_second_opinion_request:
        Web.View.Visits.render_us_board_second_opinion_request(requests_with_specialists_history)
    }
  end

  def render("us_board_specialists.proto", %{specialists: specialists}) do
    %Proto.AdminPanel.FetchUSBoardSpecialistsResponse{
      specialists:
        Enum.map(
          specialists,
          &Web.View.SpecialistProfileV2.render_admin_panel_us_board_specialist/1
        )
    }
  end

  defp add_specialist_info_to_history(specialists_history, specialists_basic_infos) do
    Enum.map(specialists_history, fn history_datum ->
      specialist_info =
        Enum.find(
          specialists_basic_infos,
          &(&1.specialist_id == history_datum.specialist_id)
        )

      history_datum
      |> Map.put(:specialist_first_name, specialist_info.first_name)
      |> Map.put(:specialist_last_name, specialist_info.last_name)
    end)
  end
end
