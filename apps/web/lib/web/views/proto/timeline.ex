defmodule Web.View.Timeline do
  def render_timeline(timeline) do
    %Proto.Timeline.Timeline{
      timeline_items: Enum.map(timeline.timeline_items, &parse_timeline_item/1)
    }
  end

  def render_new_timeline_item(timeline_item, specialists) do
    %Proto.Timeline.NewTimelineItem{
      record_id: timeline_item.timeline_id,
      timeline_item: parse_timeline_item(timeline_item),
      # DEPRECATED
      # we can do this because all timeline items had only one specialist until now
      specialist: specialists |> List.first() |> render_specialist(),
      specialists: Enum.map(specialists, &Web.View.Generics.render_specialist/1)
    }
  end

  # DEPRECATED
  def render_specialist(nil), do: nil

  def render_specialist(%Web.SpecialistGenericData{} = specialist_generic_data) do
    %Proto.Timeline.Specialist{
      id: specialist_generic_data.specialist.id,
      first_name: specialist_generic_data.basic_info.first_name,
      last_name: specialist_generic_data.basic_info.last_name,
      avatar_url: specialist_generic_data.basic_info.image_url,
      type:
        specialist_generic_data.specialist.type
        |> String.to_existing_atom()
        |> Proto.Timeline.Specialist.Type.value(),
      medical_categories: specialist_generic_data.deprecated
    }
  end

  defp parse_timeline_item(timeline_item) do
    %Proto.Timeline.TimelineItem{
      id: timeline_item.id,
      timestamp:
        timeline_item.inserted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix(),
      comments_counter: timeline_item.comments_counter,
      item: parse_item(timeline_item)
    }
  end

  defp parse_item(%{call: %{} = call}) do
    call = %Proto.Timeline.TimelineItem.Call{
      specialist_id: call.specialist_id,
      category_id: call.medical_category_id
    }

    {:call, call}
  end

  defp parse_item(%{call_recording: %{} = call_recording}) do
    call_recording = %Proto.Timeline.TimelineItem.CallRecording{
      video_url: video_url(call_recording),
      thumbnail_url: Upload.signed_download_url(call_recording.thumbnail_gcs_path),
      session_id: call_recording.session_id
    }

    {:call_recording, call_recording}
  end

  defp parse_item(%{dispatch_request: %{} = dispatch_request}) do
    dispatch_request = %Proto.Timeline.TimelineItem.DispatchRequest{
      requester_id: dispatch_request.requester_id,
      patient_location:
        dispatch_request.patient_location_address |> Web.View.Dispatches.render_patient_location()
    }

    {:dispatch_request, dispatch_request}
  end

  defp parse_item(%{doctor_invitation: %{} = doctor_invitation}) do
    doctor_invitation = %Proto.Timeline.TimelineItem.DoctorInvitation{
      specialist_id: doctor_invitation.specialist_id,
      medical_category_id: doctor_invitation.medical_category_id
    }

    {:doctor_invitation, doctor_invitation}
  end

  defp parse_item(%{vitals: %{} = vitals}) do
    vitals = %Proto.Timeline.TimelineItem.Vitals{
      nurse_id: vitals.nurse_id,
      vitals_entry: Web.View.Vitals.render_vitals_entry(vitals)
    }

    {:vitals, vitals}
  end

  defp parse_item(%{vitals_v2: %{} = vitals}) do
    vitals = Web.View.EMR.render_vitals(vitals)

    {:vitals_v2, vitals}
  end

  defp parse_item(%{ordered_tests_bundle: %{} = ordered_tests_bundle}) do
    ordered_tests = Web.View.EMR.render_ordered_tests(ordered_tests_bundle)

    ordered_tests_bundle = %Proto.Timeline.TimelineItem.OrderedTests{
      specialist_id: ordered_tests_bundle.specialist_id,
      items: ordered_tests
    }

    {:ordered_tests, ordered_tests_bundle}
  end

  defp parse_item(%{medications_bundle: %{medications: medications} = medications_bundle}) do
    medications_bundle = %Proto.Timeline.TimelineItem.Medications{
      specialist_id: medications_bundle.specialist_id,
      items: Web.View.EMR.render_medications(medications)
    }

    {:medications, medications_bundle}
  end

  defp parse_item(%{hpi: %{} = hpi}) do
    provided_hpi = %Proto.Timeline.TimelineItem.ProvidedHPI{
      hpi: Web.View.EMR.render_hpi(hpi)
    }

    {:provided_hpi, provided_hpi}
  end

  defp video_url(call_recording) do
    if call_recording.video_s3_path do
      EMR.PatientRecords.VideoRecordings.s3_download_url(call_recording.video_s3_path)
    else
      Upload.signed_download_url(call_recording.video_gcs_path)
    end
  end
end
