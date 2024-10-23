defmodule Web.DoctorPresenceChannelTest do
  use Web.ChannelCase, async: true

  alias Web.DoctorChannel
  alias Web.DoctorPresenceChannel

  @moduletag :skip

  setup do
    %{
      presence_socket: socket(Web.Socket, 0, %{current_specialist_id: 1, type: :GP}),
      doctor_socket: socket(Web.Socket, 0, %{current_specialist_id: 0, type: :EXTERNAL})
    }
  end

  test "pushes initial state on join", %{presence_socket: presence_socket} do
    :ok = join_doctor_presence_channel(presence_socket)

    assert_push "presence_state", %{proto: %Proto.Presence.PresenceState{presences: []}}
  end

  test "brodcast presence diff when doctor joins channel", %{
    presence_socket: presence_socket,
    doctor_socket: doctor_socket
  } do
    :ok = join_doctor_presence_channel(presence_socket)
    {:ok, _doctor_socket} = join_doctor_channel(doctor_socket)

    assert_broadcast "presence_diff", %{
      proto: %Proto.Presence.PresenceDiff{
        joins: [%Proto.Presence.Presence{id: 0, metadata: [_]}],
        leaves: []
      }
    }
  end

  test "brodcast presence diff when doctor leaves channel", %{
    presence_socket: presence_socket,
    doctor_socket: doctor_socket
  } do
    :ok = join_doctor_presence_channel(presence_socket)
    {:ok, doctor_socket} = join_doctor_channel(doctor_socket)
    :ok = leave_doctor_channel(doctor_socket)

    assert_broadcast "presence_diff", %{
      proto: %Proto.Presence.PresenceDiff{
        joins: [],
        leaves: [%Proto.Presence.Presence{id: 0, metadata: [_]}]
      }
    }
  end

  defp join_doctor_presence_channel(presence_socket) do
    {:ok, _, _presence_socket} =
      subscribe_and_join(presence_socket, DoctorPresenceChannel, "doctor_presence")

    :ok
  end

  defp join_doctor_channel(doctor_socket) do
    {:ok, _, doctor_socket} = subscribe_and_join(doctor_socket, DoctorChannel, "doctor")

    {:ok, doctor_socket}
  end

  defp leave_doctor_channel(doctor_socket) do
    Process.unlink(doctor_socket.channel_pid)

    ref = leave(doctor_socket)
    assert_reply ref, :ok

    :ok
  end
end
