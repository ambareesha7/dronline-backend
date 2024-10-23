defmodule Web.Api.Visits.MedicalCategoryCalendarControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Visits.GetMedicalCategoryCalendarResponse

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns free timeslots of selected medical category", %{conn: conn} do
      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      medical_category = VisitsScheduling.Factory.insert(:medical_category)

      _ =
        Postgres.Repo.insert_all("specialists_medical_categories", [
          %{specialist_id: doctor.id, medical_category_id: medical_category.id}
        ])

      date = ~D[2100-11-15]
      start_time = ~N[2100-11-15T12:00:00] |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      params = %{"month" => date |> Timex.to_unix() |> to_string()}
      path = visits_medical_category_calendar_path(conn, :show, medical_category)
      conn = get(conn, path, params)

      assert %GetMedicalCategoryCalendarResponse{
               medical_category_timeslots: [timeslot]
             } = proto_response(conn, 200, GetMedicalCategoryCalendarResponse)

      assert timeslot == %Proto.Visits.MedicalCategoryTimeslot{
               start_time: start_time,
               available_specialist_ids: [doctor.id]
             }
    end
  end
end
