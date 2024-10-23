defmodule Web.View.EMR do
  def render_record(record, basic_infos_map) do
    Sentry.Context.set_extra_context(%{record: record})

    %Proto.EMR.PatientRecord{
      record_id: record.id,
      insurance_provider_name: insurance_provider_name(record),
      insurance_member_id: insurance_member_id(record),
      start_date: record.inserted_at |> Web.View.Generics.render_datetime(),
      end_date: record.closed_at |> Web.View.Generics.render_datetime(),
      created: parse_created(record.created_by_specialist_id, basic_infos_map),
      type: parse_type(record.type, record)
    }
  end

  def render_hpi(hpi) do
    %Proto.EMR.HPI{
      form: hpi.form,
      inserted_at: hpi.inserted_at |> Web.View.Generics.render_datetime()
    }
  end

  def render_call_recording(call_recording) do
    %Proto.EMR.GetRecordCallRecordingsResponse.CallRecording{
      video_url: video_url(call_recording),
      thumbnail_url: Upload.signed_download_url(call_recording.thumbnail_gcs_path),
      session_id: call_recording.session_id,
      inserted_at: call_recording.inserted_at |> Timex.to_unix()
    }
  end

  defp video_url(call_recording) do
    if call_recording.video_s3_path do
      EMR.PatientRecords.VideoRecordings.s3_download_url(call_recording.video_s3_path)
    else
      Upload.signed_download_url(call_recording.video_gcs_path)
    end
  end

  def render_timeline_item_comment(
        %EMR.PatientRecords.Timeline.Item.Comment{} = timeline_item_comment
      ) do
    %Proto.EMR.TimelineItemComment{
      id: timeline_item_comment.id,
      commented_by_specialist_id: timeline_item_comment.commented_by_specialist_id,
      body: timeline_item_comment.body,
      inserted_at: timeline_item_comment.inserted_at |> Timex.to_unix()
    }
  end

  def render_new_timeline_item_comment(
        %EMR.PatientRecords.Timeline.Item.Comment{} = timeline_item_comment,
        updated_comments_counter,
        %Web.SpecialistGenericData{} = specialist_generic_data
      )
      when is_integer(updated_comments_counter) do
    %Proto.EMR.NewTimelineItemComment{
      patient_id: timeline_item_comment.patient_id,
      record_id: timeline_item_comment.record_id,
      timeline_item_id: timeline_item_comment.timeline_item_id,
      timeline_item_comment: render_timeline_item_comment(timeline_item_comment),
      specialist: Web.View.Generics.render_specialist(specialist_generic_data),
      updated_comments_counter: updated_comments_counter
    }
  end

  def render_vitals(nil), do: nil

  def render_vitals(%EMR.PatientRecords.Vitals{} = vitals) do
    %Proto.EMR.Vitals{
      height: Web.View.Generics.render_height(vitals.height),
      weight: Web.View.Generics.render_weight(vitals.weight),
      blood_pressure_systolic: vitals.blood_pressure_systolic,
      blood_pressure_diastolic: vitals.blood_pressure_diastolic,
      pulse: vitals.pulse,
      respiratory_rate: vitals.respiratory_rate,
      body_temperature: vitals.body_temperature,
      physical_exam: vitals.physical_exam,
      record_id: vitals.record_id,
      provided_by_nurse_id: vitals.provided_by_nurse_id,
      inserted_at: Web.View.Generics.render_datetime(vitals.inserted_at)
    }
  end

  def render_ordered_tests(%EMR.PatientRecords.OrderedTestsBundle{
        ordered_tests: ordered_tests
      }) do
    render_ordered_tests(ordered_tests)
  end

  def render_ordered_tests(ordered_tests) do
    ordered_tests
    |> Enum.map(fn %EMR.PatientRecords.OrderedTest{
                     medical_test_id: id,
                     description: description,
                     medical_test: %EMR.PatientRecords.MedicalLibrary.Test{
                       name: name
                     }
                   } ->
      %Proto.EMR.OrderedTestsItem{
        description: description,
        test: %Proto.EMR.MedicalTest{
          id: id,
          name: name
        }
      }
    end)
  end

  def render_medications_bundle(%EMR.Medications.MedicationsBundle{} = bundle),
    do: do_render_medications_bundle(bundle)

  def render_medications_bundle(%EMR.PatientRecords.MedicationsBundle{} = bundle),
    do: do_render_medications_bundle(bundle)

  defp do_render_medications_bundle(
         %{
           id: id,
           patient_id: patient_id,
           specialist_id: specialist_id,
           medications: medications,
           inserted_at: inserted_at
         } = params
       ) do
    %Proto.EMR.MedicationsBundle{
      id: id,
      patient_id: patient_id,
      specialist_id: specialist_id,
      medications: render_medications(medications),
      inserted_at: inserted_at |> Timex.to_unix(),
      payments_params: params |> Map.get(:payments_params) |> parse_payments_params
    }
  end

  def render_medications(medications) do
    medications
    |> Enum.map(fn %{
                     name: name,
                     direction: direction,
                     quantity: quantity,
                     refills: refills,
                     price_aed: price_aed
                   } ->
      %Proto.EMR.MedicationsItem{
        name: name,
        direction: direction,
        quantity: quantity,
        refills: refills,
        price_aed: price_aed
      }
    end)
  end

  def render_procedures_bundle(%EMR.PatientRecords.MedicalSummary{
        specialist_id: specialist_id,
        procedures: procedures,
        inserted_at: inserted_at,
        timeline: timeline
      }) do
    %Proto.EMR.ProceduresBundle{
      specialist_id: specialist_id,
      patient_id: timeline.patient_id,
      procedures:
        procedures
        |> Enum.map(fn %EMR.PatientRecords.MedicalLibrary.Procedure{name: name} -> name end),
      inserted_at: inserted_at |> Timex.to_unix()
    }
  end

  def render_ordered_tests_bundle(%EMR.PatientRecords.OrderedTestsBundle{
        patient_id: patient_id,
        specialist_id: specialist_id,
        inserted_at: inserted_at,
        ordered_tests: ordered_tests
      }) do
    %Proto.EMR.TestsBundle{
      patient_id: patient_id,
      specialist_id: specialist_id,
      inserted_at: inserted_at |> Timex.to_unix(),
      tests: Enum.map(ordered_tests, &render_ordered_test/1)
    }
  end

  defp render_ordered_test(%EMR.PatientRecords.OrderedTest{
         description: description,
         medical_test: %EMR.PatientRecords.MedicalLibrary.Test{
           name: name,
           medical_tests_category: %EMR.PatientRecords.MedicalLibrary.TestsCategory{
             name: category_name
           }
         }
       }) do
    %Proto.EMR.Test{
      description: description,
      name: name,
      category_name: category_name
    }
  end

  def render_medical_summary(%EMR.PatientRecords.MedicalSummary{} = medical_summary) do
    %Proto.EMR.MedicalSummary{
      medical_summary_data: render_medical_summary_data(medical_summary.data),
      specialist_id: medical_summary.specialist_id,
      inserted_at: medical_summary.inserted_at |> Timex.to_unix(),
      conditions: render_conditions(medical_summary.conditions),
      procedures: render_procedures(medical_summary.procedures),
      is_draft: medical_summary.is_draft,
      edited_at: medical_summary.edited_at |> Web.View.Generics.render_datetime()
    }
  end

  def render_medical_summary_draft(%EMR.PatientRecords.MedicalSummary{} = medical_summary) do
    %Proto.EMR.MedicalSummaryDraft{
      medical_summary_data: render_medical_summary_data(medical_summary.data),
      conditions: render_conditions(medical_summary.conditions),
      procedures: render_procedures(medical_summary.procedures)
    }
  end

  def render_medical_summary_draft(nil), do: nil

  def render_latest_medical_summary(%EMR.PatientRecords.MedicalSummary{} = medical_summary) do
    %Proto.EMR.MedicalSummary{
      medical_summary_data: render_medical_summary_data(medical_summary.data),
      conditions: render_conditions(medical_summary.conditions),
      procedures: render_procedures(medical_summary.procedures)
    }
  end

  def render_latest_medical_summary(nil), do: nil

  def render_medical_summary_data(data) do
    Proto.EMR.MedicalSummaryData.decode(data)
  end

  def render_conditions(conditions) do
    Enum.map(
      conditions,
      fn %EMR.PatientRecords.MedicalLibrary.Condition{id: id, name: name} ->
        %Proto.EMR.MedicalCondition{
          id: id,
          name: name
        }
      end
    )
  end

  def render_procedures(procedures) do
    Enum.map(
      procedures,
      fn %EMR.PatientRecords.MedicalLibrary.Procedure{id: id, name: name} ->
        %Proto.EMR.MedicalProcedure{
          id: id,
          name: name
        }
      end
    )
  end

  # DEPRECATED
  def render_specialist(%Web.SpecialistGenericData{} = specialist_generic_data) do
    %Proto.EMR.Specialist{
      type:
        specialist_generic_data.specialist.type
        |> String.to_existing_atom()
        |> Proto.Timeline.Specialist.Type.value(),
      first_name: specialist_generic_data.basic_info.first_name,
      last_name: specialist_generic_data.basic_info.last_name,
      avatar_url: specialist_generic_data.basic_info.image_url,
      medical_categories: specialist_generic_data.deprecated,
      package_type:
        specialist_generic_data.specialist.package_type
        |> String.to_existing_atom()
        |> Proto.EMR.Specialist.PackageType.value()
    }
  end

  defguardp has_key?(map, key) when :erlang.is_map_key(key, map)

  defp parse_created(nil, _map) do
    {:automatically, %Proto.EMR.PatientRecord.Automatically{}}
  end

  defp parse_created(specialist_id, basic_infos_map)
       when is_integer(specialist_id) and has_key?(basic_infos_map, specialist_id) do
    basic_info = basic_infos_map[specialist_id]

    {:by_specialist,
     %Proto.EMR.PatientRecord.Specialist{
       specialist_id: basic_info.specialist_id,
       first_name: basic_info.first_name,
       last_name: basic_info.last_name,
       avatar_url: basic_info.image_url
     }}
  end

  defp parse_type(:MANUAL, record) do
    {:manually,
     %Proto.EMR.PatientRecord.Manually{
       created_by_specialist_id: record.created_by_specialist_id,
       with_specialist_id: record.with_specialist_id
     }}
  end

  defp parse_type(:AUTO, record) do
    {:urgent_care,
     %Proto.EMR.PatientRecord.UrgentCare{
       with_specialist_id: record.with_specialist_id
     }}
  end

  defp parse_type(:VISIT, record) do
    {:scheduled,
     %Proto.EMR.PatientRecord.Scheduled{
       with_specialist_id: record.with_specialist_id
     }}
  end

  defp parse_type(:IN_OFFICE, record) do
    {:scheduled,
     %Proto.EMR.PatientRecord.Scheduled{
       with_specialist_id: record.with_specialist_id
     }}
  end

  defp parse_type(:CALL, record) do
    {:call,
     %Proto.EMR.PatientRecord.Call{
       with_specialist_id: record.with_specialist_id
     }}
  end

  defp parse_type(:US_BOARD, record) do
    {:us_board,
     %Proto.EMR.PatientRecord.USBoard{
       with_specialist_id: record.with_specialist_id,
       us_board_request_id: record.us_board_request_id
     }}
  end

  defp insurance_provider_name(%EMR.PatientRecords.PatientRecord{
         insurance_account: %{insurance_provider: %{name: name}}
       }) do
    name
  end

  defp insurance_provider_name(_), do: nil

  defp insurance_member_id(%EMR.PatientRecords.PatientRecord{
         insurance_account: %{member_id: member_id}
       }),
       do: member_id

  defp insurance_member_id(_), do: nil

  defp parse_payments_params(nil), do: nil

  defp parse_payments_params(payment) do
    %Proto.Generics.PaymentsParams{
      amount: Integer.to_string(payment.price.amount),
      currency: Atom.to_string(payment.price.currency),
      payment_method: payment.payment_method,
      transaction_reference: payment.transaction_reference
    }
  end
end
