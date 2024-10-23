defmodule Web.PanelApi.EMR.MedicalSummariesControllerTest do
  use Web.ConnCase, async: true
  use Oban.Testing, repo: Postgres.Repo
  import Mockery

  alias Payouts.PendingWithdrawals.PendingWithdrawal

  alias Proto.EMR.AddMedicalSummaryDraftRequest
  alias Proto.EMR.AddMedicalSummaryRequest
  alias Proto.EMR.GetMedicalSummariesResponse
  alias Proto.EMR.ShowMedicalSummaryDraftResponse

  alias EMR.PatientRecords.MedicalSummary
  alias EMR.PatientRecords.MedicalSummary.PendingSummary

  describe "GET index" do
    setup [:authenticate_nurse]

    test "succeeds", %{conn: conn, current_nurse: current_nurse} do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      _medical_credentials =
        SpecialistProfile.Factory.insert(:medical_credentials,
          specialist_id: current_nurse.id,
          dea_number_url: "krypto"
        )

      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      request_data = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary"),
        skip_patient_notification: true
      }

      {:ok, _medical_summary} =
        EMR.create_medical_summary(current_nurse.id, timeline.id, request_data, UUID.uuid4())

      conn = get(conn, panel_emr_medical_summaries_path(conn, :index, patient.id, timeline.id))

      assert %GetMedicalSummariesResponse{medical_summaries: [_medical_summary]} =
               proto_response(conn, 200, GetMedicalSummariesResponse)
    end
  end

  describe "POST create" do
    setup [:authenticate_gp, :proto_content]

    test """
         - creates medical summary, resolves pending one and removes draft
         - creates Pending Withdrawal
         """,
         %{
           conn: conn,
           current_gp: current_gp
         } do
      patient = PatientProfile.Factory.insert(:patient)
      {:ok, token_entry} = Authentication.Patient.AuthTokenEntry.create(patient.id)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)
      mock(EMR, [generate_record_pdf_for_patient: 2], {:ok, :erlang.term_to_binary(:mock)})

      _ =
        UrgentCare.RequestFactory.insert(%{patient_id: patient.id, patient_record_id: timeline.id})

      _us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      medical_category_id = 1

      _visit =
        Visits.Factory.insert(:ended_visit,
          specialist_id: current_gp.id,
          patient_id: patient.id,
          chosen_medical_category_id: medical_category_id,
          record_id: timeline.id
        )

      _prices =
        SpecialistProfile.Factory.insert(:prices, %{
          specialist_id: current_gp.id,
          medical_category_id: medical_category_id,
          price_minutes_15: 99
        })

      {:ok, :created} = PendingSummary.create(patient.id, timeline.id, current_gp.id)
      assert {:ok, _} = Postgres.Repo.fetch_one(PendingSummary)

      medical_summary_params = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(%{
            interview_summary: "interview_summary"
          })
      }

      summary_proto =
        medical_summary_params
        |> Map.merge(%{skip_patient_notification: true})
        |> Proto.validate!(AddMedicalSummaryRequest)
        |> AddMedicalSummaryRequest.new()
        |> AddMedicalSummaryRequest.encode()

      summary_draft_proto =
        medical_summary_params
        |> Proto.validate!(AddMedicalSummaryDraftRequest)
        |> AddMedicalSummaryDraftRequest.new()

      {:ok, _summary_draft_2} =
        MedicalSummary.create_draft(current_gp.id, timeline.id, summary_draft_proto)

      path = panel_emr_medical_summaries_path(conn, :create, patient.id, timeline.id)
      conn = post(conn, path, summary_proto)

      assert response(conn, 201)

      enqueued_jobs = all_enqueued()

      assert Enum.any?(enqueued_jobs, fn job ->
               job.args["type"] == "URGENT_CARE_SUMMARY"
               job.args["token"] == token_entry.auth_token
             end)

      assert {:error, :not_found} = Postgres.Repo.fetch_one(PendingSummary)
      refute MedicalSummary.fetch_draft(current_gp.id, timeline.id)

      assert %PendingWithdrawal{
               amount: 99
             } = Postgres.Repo.one(PendingWithdrawal)

      assert {:error, :not_found} =
               Postgres.Repo.fetch_one(NotificationsWrite.PatientNotification)
    end

    test "creates Patient notification only if params.skip_patient_notification == false",
         %{
           conn: conn,
           current_gp: current_gp
         } do
      _us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      _visit =
        Visits.Factory.insert(:ended_visit,
          specialist_id: current_gp.id,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          record_id: timeline.id
        )

      _prices =
        SpecialistProfile.Factory.insert(:prices, %{
          specialist_id: current_gp.id,
          medical_category_id: 1,
          price_minutes_15: 99
        })

      medical_summary_params = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        skip_patient_notification: false,
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(%{
            interview_summary: "interview_summary"
          })
      }

      summary_proto =
        medical_summary_params
        |> Proto.validate!(AddMedicalSummaryRequest)
        |> AddMedicalSummaryRequest.new()
        |> AddMedicalSummaryRequest.encode()

      path = panel_emr_medical_summaries_path(conn, :create, patient.id, timeline.id)
      conn = post(conn, path, summary_proto)

      assert response(conn, 201)

      assert {:ok, _} = Postgres.Repo.fetch_one(NotificationsWrite.PatientNotification)
    end

    test "moves US board request to done for US board visits", %{
      conn: conn,
      current_gp: current_gp
    } do
      us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      second_opinion_params =
        Visits.Factory.second_opinion_request_default_params(%{
          patient_id: patient.id,
          status: :call_scheduled
        })

      {:ok, %{id: request_id}} =
        Visits.request_us_board_second_opinion(second_opinion_params)

      visit =
        Visits.Factory.insert(:ended_visit,
          specialist_id: current_gp.id,
          patient_id: patient.id,
          chosen_medical_category_id: us_board_medical_category.id,
          record_id: timeline.id
        )

      assign_request_to_visit(request_id, visit.id)

      medical_summary_params = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        skip_patient_notification: false,
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(%{
            interview_summary: "interview_summary"
          })
      }

      summary_proto =
        medical_summary_params
        |> Proto.validate!(AddMedicalSummaryRequest)
        |> AddMedicalSummaryRequest.new()
        |> AddMedicalSummaryRequest.encode()

      path = panel_emr_medical_summaries_path(conn, :create, patient.id, timeline.id)
      conn = post(conn, path, summary_proto)

      assert response(conn, 201)

      assert {:ok, _} = Postgres.Repo.fetch_one(NotificationsWrite.PatientNotification)

      assert Postgres.Repo.get_by(Visits.USBoard.SecondOpinionRequest, %{
               id: request_id,
               status: :done
             })
    end

    test "creates medical summary for urgent care (without visit)", %{
      conn: conn
    } do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      medical_summary_params = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        skip_patient_notification: false,
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(%{
            interview_summary: "interview_summary"
          })
      }

      summary_proto =
        medical_summary_params
        |> Proto.validate!(AddMedicalSummaryRequest)
        |> AddMedicalSummaryRequest.new()
        |> AddMedicalSummaryRequest.encode()

      path = panel_emr_medical_summaries_path(conn, :create, patient.id, timeline.id)
      conn = post(conn, path, summary_proto)

      assert response(conn, 201)

      assert {:ok, _} = Postgres.Repo.fetch_one(NotificationsWrite.PatientNotification)
    end
  end

  describe "POST create_draft" do
    setup [:authenticate_gp, :proto_content]

    test "creates medical summary draft, doesn't resolve pending one", %{
      conn: conn,
      current_gp: current_gp
    } do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      {:ok, :created} = PendingSummary.create(patient.id, timeline.id, current_gp.id)
      assert {:ok, _} = Postgres.Repo.fetch_one(PendingSummary)

      summary_proto =
        %{
          conditions: [],
          procedures: [],
          medical_summary_data:
            Proto.EMR.MedicalSummaryData.new(%{
              interview_summary: "interview_summary"
            })
        }
        |> Proto.validate!(AddMedicalSummaryDraftRequest)
        |> AddMedicalSummaryDraftRequest.new()
        |> AddMedicalSummaryDraftRequest.encode()

      path = panel_emr_medical_summaries_path(conn, :create_draft, patient.id, timeline.id)
      conn = post(conn, path, summary_proto)

      assert response(conn, 201)
      assert {:ok, _} = Postgres.Repo.fetch_one(PendingSummary)

      assert {:ok,
              %MedicalSummary{
                is_draft: true
              }} = Postgres.Repo.fetch_one(MedicalSummary)
    end
  end

  describe "POST skip" do
    setup [:authenticate_gp, :proto_content]

    test "removes pending medical summary, and draft for current specialist", %{
      conn: conn,
      current_gp: current_gp
    } do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      {:ok, :created} = PendingSummary.create(patient.id, timeline.id, current_gp.id)

      draft_proto =
        AddMedicalSummaryDraftRequest.new(%{
          conditions: [],
          procedures: [],
          medical_summary_data:
            Proto.EMR.MedicalSummaryData.new(%{
              interview_summary: "interview_summary"
            })
        })

      _resp = MedicalSummary.create_draft(current_gp.id, timeline.id, draft_proto)

      assert {:ok, _} = Postgres.Repo.fetch_one(PendingSummary)
      assert {:ok, _} = Postgres.Repo.fetch_one(MedicalSummary)

      path = panel_emr_medical_summaries_path(conn, :skip, patient.id, timeline.id)
      conn = post(conn, path)

      assert response(conn, 200)
      assert {:error, :not_found} = Postgres.Repo.fetch_one(PendingSummary)
      assert {:error, :not_found} = Postgres.Repo.fetch_one(MedicalSummary)
    end
  end

  describe "GET show_draft" do
    setup [:authenticate_nurse]

    test "returns Medical Summary draft if it exists, or nil", %{
      conn: conn,
      current_nurse: current_nurse
    } do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)

      request_data = %{
        conditions: [condition.id],
        procedures: [],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary")
      }

      {:ok, _medical_summary} =
        EMR.create_medical_summary_draft(current_nurse.id, timeline.id, request_data)

      conn_1 = conn_2 = conn

      conn_1 =
        get(
          conn_1,
          panel_emr_medical_summaries_path(conn_1, :show_draft, patient.id, timeline.id)
        )

      assert %ShowMedicalSummaryDraftResponse{
               medical_summary_draft: %{
                 conditions: [_condition],
                 procedures: [],
                 medical_summary_data: _data
               }
             } = proto_response(conn_1, 200, ShowMedicalSummaryDraftResponse)

      conn_2 = get(conn_2, panel_emr_medical_summaries_path(conn_2, :show_draft, patient.id, 2))

      assert %ShowMedicalSummaryDraftResponse{
               medical_summary_draft: nil
             } = proto_response(conn_2, 200, ShowMedicalSummaryDraftResponse)
    end
  end

  defp assign_request_to_visit(request_id, visit_id) do
    Visits.USBoard.SecondOpinionRequest
    |> Postgres.Repo.get(request_id)
    |> Visits.USBoard.SecondOpinionRequest.changeset(%{visit_id: visit_id})
    |> Postgres.Repo.update()
  end
end
