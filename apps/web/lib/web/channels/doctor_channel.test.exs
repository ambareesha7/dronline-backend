defmodule Web.DoctorChannelTest do
  use Web.ChannelCase, async: true

  alias Web.DoctorChannel

  alias Proto.Channels.SocketMessage.ChannelPayload
  defp timeout, do: 5000

  describe "join/3" do
    test "with valid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :EXTERNAL})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, DoctorChannel, "doctor")
    end

    test "with invalid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})

      assert {:error, %{}} = subscribe_and_join(socket, DoctorChannel, "doctor")
    end
  end

  test "PING-PONG temporary events" do
    socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :EXTERNAL})
    {:ok, _join_payload, socket} = subscribe_and_join(socket, DoctorChannel, "doctor")

    payload = "ping text"

    ref = push(socket, "ping", payload)
    assert_reply(ref, :ok, _, timeout())
    assert_push("pong", _payload, timeout())
  end

  describe "handle_in" do
    test "accept_doctor_category_invitation" do
      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      socket = socket(Web.Socket, 0, %{current_specialist_id: doctor.id, type: :EXTERNAL})
      {:ok, _join_payload, socket} = subscribe_and_join(socket, DoctorChannel, "doctor")

      payload = %Proto.Calls.AcceptDoctorCategoryInvitation{
        call_id: "123",
        category_id: 0
      }

      ref = push(socket, "accept_doctor_category_invitation", payload)
      assert_reply(ref, :ok, _, timeout())
    end
  end

  describe "handling `active_package_update` messages" do
    test "the message pushed to freelance doctors (EXTERNAL)" do
      specialist_id = 0
      socket = socket(Web.Socket, 0, %{current_specialist_id: specialist_id, type: :EXTERNAL})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, DoctorChannel, "doctor")

      Membership.ChannelBroadcast.push(%{
        topic: "doctor",
        event: "active_package_update",
        payload: %{
          proto: %Proto.Membership.ActivePackageUpdate{
            type: ""
          },
          external_id: specialist_id
        }
      })

      assert_push("active_package_update", %{external_id: ^specialist_id}, timeout())
    end

    test "the message is NOT pushed to other freelancers" do
      specialist_id = 0
      other_specialist_id = 1

      socket = socket(Web.Socket, 0, %{current_specialist_id: specialist_id, type: :EXTERNAL})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, DoctorChannel, "doctor")

      Membership.ChannelBroadcast.push(%{
        topic: "doctor",
        event: "active_package_update",
        payload: %{
          proto: %Proto.Membership.ActivePackageUpdate{
            type: ""
          },
          external_id: other_specialist_id
        }
      })

      refute_push("active_package_update", _, timeout())
    end
  end
end
