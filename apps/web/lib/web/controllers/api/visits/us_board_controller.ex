defmodule Web.Api.Visits.USBoardController do
  use Web, :controller

  action_fallback(Web.FallbackController)

  def index_us_board_second_opinion(
        %{
          assigns: %{
            current_patient_id: patient_id
          }
        } = conn,
        _params
      ) do
    with {:ok, us_board_requests} <- Visits.fetch_patient_second_opinion_requests(patient_id) do
      render(conn, "index.proto", %{us_board_requests: us_board_requests})
    end
  end

  def us_board_second_opinion(
        conn,
        %{"id" => request_id}
      ) do
    with {:ok, us_board_request} <- Visits.fetch_us_board_second_opinion(request_id) do
      render(conn, "show.proto", %{request: us_board_request})
    end
  end

  @decode Proto.Visits.RequestUSBoardSecondOpinionRequest
  def request_us_board_second_opinion(
        %{
          assigns: %{
            current_patient_id: patient_id,
            protobuf: %{
              patient_description: patient_description,
              patient_email: patient_email,
              files: files,
              payments_params: payments_params
            }
          }
        } = conn,
        _params
      ) do
    params = %{
      patient_id: patient_id,
      patient_description: patient_description,
      patient_email: patient_email,
      files: Enum.map(files, &Map.from_struct/1),
      status: :requested,
      transaction_reference: payments_params.transaction_reference
    }

    {:ok, us_board_request} = Visits.request_us_board_second_opinion(params)

    render(conn, "create.proto", %{us_board_request: us_board_request})
  end
end

defmodule Web.Api.Visits.USBoardView do
  use Web, :view

  def render("index.proto", %{us_board_requests: us_board_requests}) do
    %Proto.Visits.USBoardSecondOpinionRequestsResponse{
      us_board_second_opinion_requests:
        Enum.map(us_board_requests, &Web.View.Visits.render_us_board_second_opinion_request/1)
    }
  end

  def render("show.proto", %{request: request}) do
    %Proto.Visits.USBoardSecondOpinionRequestResponse{
      us_board_second_opinion_request:
        Web.View.Visits.render_us_board_second_opinion_request(request)
    }
  end

  def render("create.proto", %{us_board_request: us_board_request}) do
    %Proto.Visits.RequestUSBoardSecondOpinionResponse{
      id: us_board_request.id
    }
  end
end
