defmodule Web.PanelApi.EMR.CommentsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.CreateTimelineItemCommentResponse
  alias Proto.EMR.GetTimelineItemCommentsResponse

  alias Proto.EMR.TimelineItemComment

  describe "GET index" do
    setup [:authenticate_gp]

    test "returns comments and associated specialists data", %{conn: conn, current_gp: current_gp} do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      timeline_item_id = UUID.uuid4()

      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_gp.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateItemComment{
        body: "TEST",
        commented_by_specialist_id: current_gp.id,
        commented_on: "HPI",
        patient_id: patient.id,
        record_id: record.id,
        timeline_item_id: timeline_item_id
      }

      {:ok, _comment, _updated_comments_counter} = EMR.create_timeline_item_comment(cmd)

      path = panel_emr_comments_path(conn, :index, patient, record, timeline_item_id)
      conn = get(conn, path)

      assert %GetTimelineItemCommentsResponse{
               timeline_item_comments: [
                 %TimelineItemComment{
                   body: "TEST",
                   commented_by_specialist_id: returned_specialist_id
                 }
               ],
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}],
               next_token: "",
               total_comments_counter: returned_total_comments_counter
             } = proto_response(conn, 200, GetTimelineItemCommentsResponse)

      assert returned_specialist_id == current_gp.id
      assert returned_total_comments_counter == 1
    end
  end

  describe "POST create" do
    setup [:proto_content, :authenticate_gp]

    defp create_timeline_item(patient_id, record_id) do
      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: patient_id,
        record_id: record_id,
        specialist_id: 1
      }

      {:ok, item} = EMR.create_call_timeline_item(cmd)

      item
    end

    test "returns comment and associated specialist data after successful comment creation", %{
      conn: conn,
      current_gp: current_gp
    } do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      timeline_item_id = create_timeline_item(patient.id, record.id).id

      proto =
        %{
          body: "TEST"
        }
        |> Proto.EMR.CreateTimelineItemCommentRequest.new()
        |> Proto.EMR.CreateTimelineItemCommentRequest.encode()

      path = panel_emr_comments_path(conn, :create, patient, record, timeline_item_id)
      conn = post(conn, path, proto)

      assert %CreateTimelineItemCommentResponse{
               timeline_item_comment: %TimelineItemComment{
                 body: "TEST",
                 commented_by_specialist_id: returned_specialist_id
               },
               specialist: %Proto.Generics.Specialist{id: returned_specialist_id},
               updated_comments_counter: 1
             } = proto_response(conn, 200, CreateTimelineItemCommentResponse)

      assert returned_specialist_id == current_gp.id
    end

    test "returns error if selected patient and record doesn't match", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      timeline_item_id = create_timeline_item(patient.id, record.id).id

      proto =
        %{
          body: "TEST"
        }
        |> Proto.EMR.CreateTimelineItemCommentRequest.new()
        |> Proto.EMR.CreateTimelineItemCommentRequest.encode()

      invalid_record_id = 0

      path = panel_emr_comments_path(conn, :create, patient, invalid_record_id, timeline_item_id)
      conn = post(conn, path, proto)

      assert response(conn, 404)
    end

    test "returns error if selected timeline_item doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      timeline_item_id = UUID.uuid4()

      proto =
        %{
          body: "TEST"
        }
        |> Proto.EMR.CreateTimelineItemCommentRequest.new()
        |> Proto.EMR.CreateTimelineItemCommentRequest.encode()

      path = panel_emr_comments_path(conn, :create, patient, record, timeline_item_id)
      conn = post(conn, path, proto)

      assert response(conn, 404)
    end

    test "returns error if selected timeline_item and record doesn't match", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      record1 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      record2 = EMR.Factory.insert(:manual_record, patient_id: patient.id)
      timeline_item_id = create_timeline_item(patient.id, record1.id).id

      proto =
        %{
          body: "TEST"
        }
        |> Proto.EMR.CreateTimelineItemCommentRequest.new()
        |> Proto.EMR.CreateTimelineItemCommentRequest.encode()

      path = panel_emr_comments_path(conn, :create, patient, record2, timeline_item_id)
      conn = post(conn, path, proto)

      assert response(conn, 404)
    end
  end
end
