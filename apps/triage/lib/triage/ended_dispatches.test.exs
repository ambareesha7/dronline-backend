defmodule Triage.EndedDispatchesTest do
  use Postgres.DataCase, async: true

  defp prepare_pending_dispatch do
    patient = PatientProfile.Factory.insert(:patient)
    gp = Authentication.Factory.insert(:specialist, type: "GP")
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    cmd = %Triage.Commands.RequestDispatchToPatient{
      patient_id: patient.id,
      patient_location_address: %{
        city: "Dubai",
        country: "United Arab Emirates",
        building_number: "1",
        postal_code: "2",
        street_name: "3"
      },
      record_id: record.id,
      region: "united-arab-emirates-dubai",
      request_id: UUID.uuid4(),
      requester_id: gp.id
    }

    {:ok, pending_dispatch} = Triage.request_dispatch_to_patient(cmd)

    pending_dispatch
  end

  defp take_dispatch(pending_dispatch) do
    nurse_id = Authentication.Factory.insert(:specialist, type: "NURSE").id

    cmd = %Triage.Commands.TakePendingDispatch{
      nurse_id: nurse_id,
      request_id: pending_dispatch.request_id
    }

    {:ok, ongoing_dispatch} = Triage.take_pending_dispatch(cmd)

    ongoing_dispatch
  end

  defp end_dispatch(ongoing_dispatch) do
    cmd = %Triage.Commands.EndDispatch{
      nurse_id: ongoing_dispatch.nurse_id,
      request_id: ongoing_dispatch.request_id
    }

    {:ok, ended_dispatch} = Triage.end_dispatch(cmd)

    ended_dispatch
  end

  defp prepare_ended_dispatches do
    dispatch1 = prepare_pending_dispatch()
    dispatch2 = prepare_pending_dispatch()
    dispatch3 = prepare_pending_dispatch()

    [dispatch2, dispatch3, dispatch1] =
      Enum.map([dispatch2, dispatch3, dispatch1], &take_dispatch/1)

    [dispatch3, dispatch1, dispatch2] =
      Enum.map([dispatch3, dispatch1, dispatch2], &end_dispatch/1)

    [dispatch1, dispatch2, dispatch3]
  end

  describe "fetch/1" do
    test "allows to ascending sort by requested_at value" do
      [dispatch1, dispatch2, dispatch3] = prepare_ended_dispatches()

      params = %{"sort_by" => "requested_at", "order" => "asc"}
      expected_order = [dispatch1.request_id, dispatch2.request_id, dispatch3.request_id]

      assert {:ok, ended_dispatches, nil} = Triage.EndedDispatch.fetch(params)
      assert Enum.map(ended_dispatches, & &1.request_id) == expected_order
    end

    test "allows to descending sort by requested_at value" do
      [dispatch1, dispatch2, dispatch3] = prepare_ended_dispatches()

      params = %{"sort_by" => "requested_at", "order" => "desc"}
      expected_order = [dispatch3.request_id, dispatch2.request_id, dispatch1.request_id]

      assert {:ok, ended_dispatches, nil} = Triage.EndedDispatch.fetch(params)
      assert Enum.map(ended_dispatches, & &1.request_id) == expected_order
    end

    test "allows to ascending sort by taken_at value" do
      [dispatch1, dispatch2, dispatch3] = prepare_ended_dispatches()

      params = %{"sort_by" => "taken_at", "order" => "asc"}
      expected_order = [dispatch2.request_id, dispatch3.request_id, dispatch1.request_id]

      assert {:ok, ended_dispatches, nil} = Triage.EndedDispatch.fetch(params)
      assert Enum.map(ended_dispatches, & &1.request_id) == expected_order
    end

    test "allows to descending sort by taken_at value" do
      [dispatch1, dispatch2, dispatch3] = prepare_ended_dispatches()

      params = %{"sort_by" => "taken_at", "order" => "desc"}
      expected_order = [dispatch1.request_id, dispatch3.request_id, dispatch2.request_id]

      assert {:ok, ended_dispatches, nil} = Triage.EndedDispatch.fetch(params)
      assert Enum.map(ended_dispatches, & &1.request_id) == expected_order
    end

    test "allows to ascending sort by ended_at value" do
      [dispatch1, dispatch2, dispatch3] = prepare_ended_dispatches()

      params = %{"sort_by" => "ended_at", "order" => "asc"}
      expected_order = [dispatch3.request_id, dispatch1.request_id, dispatch2.request_id]

      assert {:ok, ended_dispatches, nil} = Triage.EndedDispatch.fetch(params)
      assert Enum.map(ended_dispatches, & &1.request_id) == expected_order
    end

    test "allows to descending sort by ended_at value" do
      [dispatch1, dispatch2, dispatch3] = prepare_ended_dispatches()

      params = %{"sort_by" => "ended_at", "order" => "desc"}
      expected_order = [dispatch2.request_id, dispatch1.request_id, dispatch3.request_id]

      assert {:ok, ended_dispatches, nil} = Triage.EndedDispatch.fetch(params)
      assert Enum.map(ended_dispatches, & &1.request_id) == expected_order
    end

    test "paginates results respecting initial ascending sorting" do
      [dispatch1, dispatch2, _dispatch3] = prepare_ended_dispatches()

      params = %{
        "sort_by" => "requested_at",
        "order" => "asc",
        "limit" => "1"
      }

      assert {:ok, [ended_dispatch], next_token} = Triage.EndedDispatch.fetch(params)
      assert ended_dispatch.request_id == dispatch1.request_id

      params = %{
        "sort_by" => "requested_at",
        "order" => "desc",
        "limit" => "1",
        "next_token" => next_token
      }

      assert {:ok, [ended_dispatch], _next_token} = Triage.EndedDispatch.fetch(params)
      assert ended_dispatch.request_id == dispatch2.request_id
    end

    test "paginates results respecting initial descending sorting" do
      [_dispatch1, dispatch2, dispatch3] = prepare_ended_dispatches()

      params = %{
        "sort_by" => "requested_at",
        "order" => "desc",
        "limit" => "1"
      }

      assert {:ok, [ended_dispatch], next_token} = Triage.EndedDispatch.fetch(params)
      assert ended_dispatch.request_id == dispatch3.request_id

      params = %{
        "sort_by" => "requested_at",
        "order" => "asc",
        "limit" => "1",
        "next_token" => next_token
      }

      assert {:ok, [ended_dispatch], _next_token} = Triage.EndedDispatch.fetch(params)
      assert ended_dispatch.request_id == dispatch2.request_id
    end
  end

  describe "get_total_count/1" do
    test "returns total count of database entries" do
      [_ended_dispatch1, _ended_dispatch2, _ended_dispatch3] = prepare_ended_dispatches()

      assert Triage.EndedDispatch.get_total_count() == 3
    end
  end
end
