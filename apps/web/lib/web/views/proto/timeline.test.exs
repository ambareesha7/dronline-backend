defmodule Web.View.TimelineTest do
  use ExUnit.Case, async: true

  test "renders dispatch request item" do
    requester_id = 7231

    additional_numbers = "1"
    building_number = "2"
    city = "Dubai"
    country = "United Arab Emirates"
    district = "3"
    postal_code = "4"
    street_name = "5"

    timeline_item = %EMR.PatientRecords.Timeline.Item{
      call: nil,
      call_id: nil,
      call_recording: nil,
      call_recording_id: nil,
      dispatch_request: %EMR.PatientRecords.Timeline.ItemData.DispatchRequest{
        id: 286,
        inserted_at: ~N[2019-06-19 15:37:49.333249],
        patient_location_address: %{
          "additional_numbers" => additional_numbers,
          "building_number" => building_number,
          "city" => city,
          "country" => country,
          "district" => district,
          "postal_code" => postal_code,
          "street_name" => street_name
        },
        record_id: 2056,
        request_id: "6187183f-5a40-4eb3-8d73-aced5a3b7120",
        requester_id: requester_id,
        updated_at: ~N[2019-06-19 15:37:49.333249]
      },
      dispatch_request_id: 286,
      doctor_invitation: nil,
      doctor_invitation_id: nil,
      id: 394,
      inserted_at: ~N[2019-06-19 15:37:49.335335],
      timeline_id: 2056,
      updated_at: ~N[2019-06-19 15:37:49.335335]
    }

    assert %Proto.Timeline.NewTimelineItem{
             timeline_item: %Proto.Timeline.TimelineItem{
               item:
                 {:dispatch_request,
                  %Proto.Timeline.TimelineItem.DispatchRequest{
                    requester_id: ^requester_id,
                    patient_location: %Proto.Dispatches.PatientLocation{
                      address: %Proto.Dispatches.PatientLocation.Address{
                        additional_numbers: ^additional_numbers,
                        building_number: ^building_number,
                        city: ^city,
                        country: ^country,
                        district: ^district,
                        postal_code: ^postal_code,
                        street_name: ^street_name
                      }
                    }
                  }}
             }
           } = Web.View.Timeline.render_new_timeline_item(timeline_item, [])
  end
end
