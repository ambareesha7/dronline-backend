defmodule Web.PanelApi.EMR.CommentsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    patient_id = String.to_integer(params["patient_id"])
    record_id = String.to_integer(params["record_id"])
    timeline_item_id = params["timeline_item_id"]

    {:ok, comments, total_comments_counter, next_token} =
      EMR.fetch_timeline_item_comments(patient_id, record_id, timeline_item_id, params)

    specialists_generic_data =
      comments
      |> Enum.map(& &1.commented_by_specialist_id)
      |> Web.SpecialistGenericData.get_by_ids()

    render(conn, "index.proto", %{
      comments: comments,
      specialists_generic_data: specialists_generic_data,
      next_token: next_token,
      total_comments_counter: total_comments_counter
    })
  end

  @decode Proto.EMR.CreateTimelineItemCommentRequest
  def create(conn, params) do
    specialist_id = conn.assigns.current_specialist_id
    body = conn.assigns.protobuf.body

    patient_id = String.to_integer(params["patient_id"])
    record_id = String.to_integer(params["record_id"])
    timeline_item_id = params["timeline_item_id"]

    with {:ok, record} <- EMR.fetch_patient_record(record_id, patient_id),
         {:timeline_item, %{} = timeline_item} <-
           {:timeline_item, EMR.get_timeline_item(timeline_item_id)},
         {:timeline_item_matches_record, true} <-
           {:timeline_item_matches_record, record.id == timeline_item.timeline_id},
         {:cmd, cmd} =
           {:cmd,
            %EMR.PatientRecords.Timeline.Commands.CreateItemComment{
              body: body,
              commented_by_specialist_id: specialist_id,
              commented_on: EMR.get_display_name_for_timeline_item(timeline_item),
              patient_id: patient_id,
              record_id: record_id,
              timeline_item_id: timeline_item_id
            }},
         {:ok, comment, updated_comments_counter} <-
           EMR.create_timeline_item_comment(cmd) do
      specialist_generic_data = Web.SpecialistGenericData.get_by_id(specialist_id)

      render(conn, "create.proto", %{
        comment: comment,
        specialist_generic_data: specialist_generic_data,
        updated_comments_counter: updated_comments_counter
      })
    else
      {:error, reason} ->
        {:error, reason}

      {:timeline_item, nil} ->
        {:error, :not_found}

      {:timeline_item_matches_record, false} ->
        {:error, :not_found}
    end
  end
end

defmodule Web.PanelApi.EMR.CommentsView do
  use Web, :view

  def render("index.proto", %{
        comments: comments,
        specialists_generic_data: specialists_generic_data,
        next_token: next_token,
        total_comments_counter: total_comments_counter
      }) do
    %Proto.EMR.GetTimelineItemCommentsResponse{
      timeline_item_comments: Enum.map(comments, &Web.View.EMR.render_timeline_item_comment/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      next_token: next_token,
      total_comments_counter: total_comments_counter
    }
  end

  def render("create.proto", %{
        comment: comment,
        specialist_generic_data: specialist_generic_data,
        updated_comments_counter: updated_comments_counter
      }) do
    %Proto.EMR.CreateTimelineItemCommentResponse{
      timeline_item_comment: Web.View.EMR.render_timeline_item_comment(comment),
      specialist: Web.View.Generics.render_specialist(specialist_generic_data),
      updated_comments_counter: updated_comments_counter
    }
  end
end
