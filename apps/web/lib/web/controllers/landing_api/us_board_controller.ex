defmodule Web.LandingApi.USBoardController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.Visits.LandingRequestUSBoardSecondOpinionRequest
  def request_second_opinion(conn, _params) do
    params =
      conn.assigns.protobuf
      |> Map.from_struct()
      |> Map.put(:status, :landing_payment_pending)
      |> Map.replace(:files, Enum.map(conn.assigns.protobuf.files, &Map.from_struct/1))
      |> Map.put(:host, conn.host)

    with {:ok, %{us_board_request_id: us_board_request_id, payment_url: payment_url}} <-
           Visits.request_second_opinion_from_landing(params) do
      render(conn, "request_second_opinion.proto", %{
        us_board_request_id: us_board_request_id,
        payment_url: payment_url
      })
    end
  end

  @decode Proto.Visits.LandingConfirmUSBoardSecondOpinionRequest
  def confirm_second_opinion_payment(conn, _params) do
    params = %{
      us_board_second_opinion_request_id: conn.assigns.protobuf.second_opinion_request_id,
      transaction_reference: conn.assigns.protobuf.transaction_reference
    }

    with :ok <- Visits.confirm_second_opinion_payment(params) do
      send_resp(conn, 201, "")
    end
  end

  @decode Proto.Visits.LandingUSBoardContactFormRequest
  def fill_contact_form(conn, _params) do
    params =
      conn.assigns.protobuf
      |> Map.from_struct()
      |> Map.put(:status, :landing_form)
      |> Map.put(:host, conn.host)

    with {:ok, _us_board_request} <-
           Visits.request_second_opinion_from_landing(params) do
      send_resp(conn, 201, "")
    end
  end
end

defmodule Web.LandingApi.USBoardView do
  use Web, :view

  def render("request_second_opinion.proto", %{
        us_board_request_id: us_board_request_id,
        payment_url: payment_url
      }) do
    %Proto.Visits.LandingRequestUSBoardSecondOpinionResponse{
      payment_url: payment_url,
      second_opinion_request_id: us_board_request_id
    }
  end
end
