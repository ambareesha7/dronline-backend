defmodule Web.PanelApi.UsBoardSecondOpinionController do
  use Web, :controller

  action_fallback(Web.FallbackController)

  def index(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, requests} <-
           Visits.fetch_specialist_second_opinion_requests(specialist_id),
         {:ok, patients} <-
           requests
           |> Enum.map(& &1.patient_id)
           |> PatientProfile.fetch_basic_infos(),
         requests <-
           Enum.map(
             requests,
             &%{
               request: &1,
               patient: Enum.find(patients, fn patient -> &1.patient_id == patient.patient_id end)
             }
           ) do
      render(conn, "index.proto", %{requests: requests})
    end
  end

  def show(conn, %{"id" => request_id}) do
    with {:ok, request} <- Visits.fetch_us_board_second_opinion(request_id) do
      render(conn, "show.proto", %{request: request})
    end
  end

  def by_visit_id(conn, %{"visit_id" => visit_id}) do
    with {:ok, request} <- Visits.fetch_second_opinion_request_by_visit_id(visit_id) do
      render(conn, "show.proto", %{request: request})
    end
  end

  @decode Proto.Visits.PostUSBoardSpecialistOpinion
  def update(conn, %{"id" => request_id}) do
    proto = conn.assigns.protobuf

    {:ok, request_with_opinion} =
      Visits.update_specialist_opinion(
        request_id,
        proto.specialist_opinion
      )

    render(conn, "show.proto", %{request: request_with_opinion})
  end

  @decode Proto.Visits.PostUSBoardSpecialistOpinion
  def submit_opinion(conn, %{"request_id" => request_id}) do
    proto = conn.assigns.protobuf

    {:ok, request_with_opinion} =
      Visits.submit_specialist_opinion(
        request_id,
        proto.specialist_opinion
      )

    render(conn, "show.proto", %{request: request_with_opinion})
  end

  def accept(conn, %{"request_id" => request_id}) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, _updated_specialist} =
      Visits.accept_us_board_second_opinion(specialist_id, request_id)

    send_resp(conn, 200, [])
  end

  def reject(conn, %{"request_id" => request_id}) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, _updated_specialist} =
      Visits.reject_us_board_second_opinion(specialist_id, request_id)

    send_resp(conn, 200, [])
  end
end

defmodule Web.PanelApi.UsBoardSecondOpinionView do
  use Web, :view

  def render("index.proto", %{requests: requests}) do
    %Proto.Visits.GetSpecialistsUSBoardOpinions{
      requested_opinions:
        Enum.map(requests, fn %{request: request, patient: patient} ->
          %Proto.Visits.SpecialistsUSBoardOpinion{
            accepted_at: specialist_accepted_at(request.assigned_specialists),
            rejected_at: specialist_rejected_at(request.assigned_specialists),
            assigned_at: specialist_assigned_at(request.assigned_specialists),
            status: Web.ProtoHelpers.map_us_board_second_opinion_status(request.status),
            id: request.id,
            patient: %Proto.Visits.USBoardPatient{
              first_name: get_or_nil(patient, :first_name),
              last_name: get_or_nil(patient, :last_name),
              email: request.patient_email,
              gender: patient |> get_or_nil(:gender) |> Web.View.Generics.parse_gender(),
              birth_date:
                patient |> get_or_nil(:birth_date) |> Web.View.Generics.render_datetime(),
              avatar_url: get_avatar_url(patient)
            }
          }
        end)
    }
  end

  def render("show.proto", %{request: request}) do
    %Proto.Visits.USBoardRequestDetails{
      files:
        Enum.map(request.files, fn file ->
          %Proto.Visits.USBoardFilesToDownload{
            download_url: Upload.signed_download_url(file.path)
          }
        end),
      patient_description: request.patient_description,
      specialist_opinion: request.specialist_opinion,
      id: request.id,
      status: Web.ProtoHelpers.map_us_board_second_opinion_status(request.status),
      inserted_at: Web.View.Generics.render_datetime(request.inserted_at)
    }
  end

  defp specialist_accepted_at(assigned_specialists) when is_list(assigned_specialists) do
    case assigned_specialists |> List.first() do
      nil ->
        nil

      assigned_specialist ->
        assigned_specialist |> Map.get(:accepted_at) |> Web.View.Generics.render_datetime()
    end
  end

  defp specialist_accepted_at(_), do: nil

  defp specialist_rejected_at(assigned_specialists) when is_list(assigned_specialists) do
    assigned_specialists
    |> Enum.find(&(&1.status == :rejected))
    |> then(fn
      nil ->
        nil

      specialist ->
        specialist
        |> Map.get(:rejected_at)
        |> Web.View.Generics.render_datetime()
    end)
  end

  defp specialist_assigned_at(assigned_specialists) when is_list(assigned_specialists) do
    case assigned_specialists |> List.first() do
      nil ->
        nil

      assigned_specialist ->
        assigned_specialist |> Map.get(:assigned_at) |> Web.View.Generics.render_datetime()
    end
  end

  defp get_or_nil(nil, _), do: nil
  defp get_or_nil(map, field), do: Map.get(map, field)

  defp get_avatar_url(nil), do: nil
  defp get_avatar_url(patient), do: Upload.signed_download_url(patient.avatar_resource_path)
end
