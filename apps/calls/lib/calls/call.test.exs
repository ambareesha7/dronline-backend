defmodule Calls.CallTest do
  use ExUnit.Case, async: false

  alias Calls.Call

  test "we can start a call and check if the call is in progress" do
    refute Call.in_progress?("wrong call_id")

    call_id = Call.start()
    :ok = Call.join(call_id, self())

    Process.sleep(100)
    assert Call.in_progress?(call_id)
  end

  test "the call process is terminated after every client exits" do
    test_pid = self()

    client_pid =
      spawn(fn ->
        call_id = Call.start()
        :ok = Call.join(call_id, self())
        send(test_pid, {:call_id, call_id})

        receive do
          :exit -> :ok
        end
      end)

    assert_receive {:call_id, call_id}
    assert Call.in_progress?(call_id)

    Process.monitor(client_pid)
    send(client_pid, :exit)
    assert_receive {:DOWN, _, _, _, _}
    Process.sleep(50)

    refute Call.in_progress?(call_id)
  end

  test "specialists can be invited to the call" do
    call_id = Call.start()
    :ok = Call.invite_specialist(call_id, "medical_category_id")
  end

  # TODO
  # test "if a specialist is invited to the call,
  # the event to leave a queue is published after the call has ended" do
  #   Process.register(self(), :test_process)
  #
  #   call_id = Call.start()
  #
  #   client_pid =
  #     spawn(fn ->
  #       :ok = Call.join(call_id, self())
  #
  #       receive do
  #         :exit -> :ok
  #       end
  #     end)
  #
  #   :ok = Call.invite_specialist(call_id, "medical_category_id")
  #
  #   send(client_pid, :exit)
  #
  #   assert_receive {:cqrs_dispatch, _}
  # end

  test "patient location can be stored inside a process" do
    call_id = Call.start()
    :ok = Call.join(call_id, self())
    :ok = Call.store_patient_location_coordinates(call_id, %{lon: 10.0, lat: 20.0})

    assert %{lon: 10.0, lat: 20.0} = Call.get_patient_location_coordinates(call_id)
  end
end
