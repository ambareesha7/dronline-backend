defmodule Web.Socket do
  use Phoenix.Socket

  ## Channels
  channel "doctor", Web.DoctorChannel
  channel "external", Web.DoctorChannel
  channel "nurse", Web.NurseChannel
  channel "gp", Web.GPChannel
  channel "patient", Web.PatientChannel

  channel "record:*", Web.RecordChannel
  channel "call:*", Web.CallChannel

  channel "doctor_presence", Web.DoctorPresenceChannel

  @not_allowed_types [
    :EXTERNAL_REJECTED,
    :NURSE_ONBOARDING,
    :GP_ONBOARDING
  ]

  def connect(params, socket) do
    salt = Application.get_env(:web, :channels_token_salt)

    case Phoenix.Token.verify(socket, salt, params["token"], max_age: :infinity) do
      {:ok, %{type: type}} when type in @not_allowed_types ->
        :error

      {:ok, %{id: id, type: :PATIENT}} ->
        socket =
          socket
          |> assign(:current_patient_id, id)
          |> assign(:device_id, params["device_id"])
          |> assign(:type, :PATIENT)

        {:ok, socket}

      {:ok, %{id: id, type: type}} ->
        socket =
          socket
          |> assign(:current_specialist_id, id)
          |> assign(:type, type)

        {:ok, socket}

      {:error, _} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given patient:
  #
  #     def id(socket), do: "patient_socket:#{socket.assigns.patient_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given patient:
  #
  #     Web.Endpoint.broadcast("patient_socket:#{patient.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
