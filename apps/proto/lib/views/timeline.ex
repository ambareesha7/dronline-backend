defmodule Proto.TimelineView do
  use Proto.View

  def render("timeline.proto", %{timeline: timeline}) do
    %{
      timeline_items:
        render_many(timeline.timeline_items, __MODULE__, "timeline_item.proto", as: :timeline_item)
    }
    |> Proto.validate!(Proto.Timeline.Timeline)
    |> Proto.Timeline.Timeline.new()
  end

  def render("timeline_item.proto", %{timeline_item: timeline_item}) do
    %{
      timestamp:
        timeline_item.inserted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix(),
      item: render_one(timeline_item, __MODULE__, "item.proto", as: :item)
    }
    |> Proto.validate!(Proto.Timeline.TimelineItem)
    |> Proto.Timeline.TimelineItem.new()
  end

  def render("specialist.proto", %{specialist: specialist}) do
    %{
      id: specialist.id,
      first_name: specialist.first_name,
      last_name: specialist.last_name,
      avatar_url: specialist.avatar_url,
      type: specialist.type |> Proto.Timeline.Specialist.Type.value(),
      medical_categories: specialist.medical_categories
    }
    |> Proto.validate!(Proto.Timeline.Specialist)
    |> Proto.Timeline.Specialist.new()
  end

  ## ITEM TYPES ##

  def render("item.proto", %{item: %{call: call}}) when not is_nil(call) do
    call =
      %{
        specialist_id: call.specialist_id,
        category_id: call.medical_category_id
      }
      |> Proto.validate!(Proto.Timeline.TimelineItem.Call)
      |> Proto.Timeline.TimelineItem.Call.new()

    {:call, call}
  end

  def render("item.proto", %{item: %{doctor_invitation: doctor_invitation}})
      when not is_nil(doctor_invitation) do
    doctor_invitation =
      %{
        specialist_id: doctor_invitation.specialist_id,
        medical_category_id: doctor_invitation.medical_category_id
      }
      |> Proto.validate!(Proto.Timeline.TimelineItem.DoctorInvitation)
      |> Proto.Timeline.TimelineItem.DoctorInvitation.new()

    {:doctor_invitation, doctor_invitation}
  end

  def render("item.proto", %{item: %{vitals: vitals}}) when not is_nil(vitals) do
    vitals =
      %{
        nurse_id: vitals.nurse_id,
        vitals_entry:
          render_one(parse_vitals(vitals), Proto.VitalsView, "vitals_entry.proto",
            as: :vitals_entry
          )
      }
      |> Proto.validate!(Proto.Timeline.TimelineItem.Vitals)
      |> Proto.Timeline.TimelineItem.Vitals.new()

    {:vitals, vitals}
  end

  def render("item.proto", %{item: %{ordered_tests_bundle: ordered_tests_bundle}})
      when not is_nil(ordered_tests_bundle) do
    ordered_tests =
      %{
        specialist_id: ordered_tests_bundle.specialist_id,
        items:
          render_many(
            parse_ordered_tests_bundle(ordered_tests_bundle),
            Proto.OrderedTestsItemView,
            "ordered_tests_item.proto",
            as: :ordered_test
          )
      }
      |> Proto.validate!(Proto.Timeline.TimelineItem.OrderedTests)
      |> Proto.Timeline.TimelineItem.OrderedTests.new()

    {:ordered_tests, ordered_tests}
  end

  defp parse_vitals(vitals) do
    %{
      id: vitals.id,
      bmi: %{
        weight: %{value: vitals.weight},
        height: %{value: vitals.height}
      },
      blood_pressure: %{
        systolic: vitals.systolic,
        diastolic: vitals.diastolic,
        pulse: vitals.pulse
      },
      ekg: %{file_url: vitals.ekg_file_url}
    }
  end

  defp parse_ordered_tests_bundle(ordered_tests_bundle) do
    ordered_tests_bundle.ordered_tests
    |> Enum.map(fn %{description: description, medical_test: test} ->
      %{
        description: description,
        test: %{
          id: test.id,
          name: test.name
        }
      }
    end)
  end
end
