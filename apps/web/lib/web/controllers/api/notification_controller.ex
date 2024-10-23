defmodule Web.Api.NotificationController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, notifications, specialist_ids, next_token} =
      NotificationsRead.fetch_notifications_for_patient(patient_id, params)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    conn
    |> render("index.proto", %{
      notifications: notifications,
      specialists_generic_data: specialists_generic_data,
      next_token: next_token
    })
  end

  def unread_count(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    unread_notifications_count =
      NotificationsRead.get_unread_notifications_count_for_patient(patient_id)

    conn
    |> render("unread_count.proto", %{
      unread_notifications_count: unread_notifications_count
    })
  end

  def mark_as_read(conn, params) do
    patient_id = conn.assigns.current_patient_id
    %{"id" => notification_id} = params

    :ok = NotificationsWrite.mark_patient_notification_as_read(patient_id, notification_id)

    unread_notifications_count =
      NotificationsRead.get_unread_notifications_count_for_patient(patient_id)

    conn
    |> render("unread_count.proto", %{unread_notifications_count: unread_notifications_count})
  end

  def mark_all_as_read(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    :ok = NotificationsWrite.mark_all_patient_notifications_as_read(patient_id)

    conn |> send_resp(200, "")
  end
end

defmodule Web.Api.NotificationView do
  use Web, :view

  def render("index.proto", %{
        notifications: notifications,
        specialists_generic_data: specialists_generic_data,
        next_token: next_token
      }) do
    %Proto.Notifications.GetPatientNotificationsResponse{
      notifications: Enum.map(notifications, &Web.Api.NotificationsView.render_notification/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      next_token: next_token
    }
  end

  def render("unread_count.proto", %{unread_notifications_count: unread_notifications_count}) do
    %Proto.Notifications.NotificationsCounterResponse{
      unread_notifications_counter: unread_notifications_count
    }
  end
end
