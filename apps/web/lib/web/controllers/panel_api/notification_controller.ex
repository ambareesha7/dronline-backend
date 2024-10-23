defmodule Web.PanelApi.NotificationController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, notifications, specialist_ids, next_token} =
      NotificationsRead.fetch_notifications_for_specialist(specialist_id, params)

    unread_notifications_count =
      NotificationsRead.get_unread_notifications_count_for_specialist(specialist_id)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    conn
    |> render("index.proto", %{
      notifications: notifications,
      specialists_generic_data: specialists_generic_data,
      unread_notifications_count: unread_notifications_count,
      next_token: next_token
    })
  end

  def unread_count(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    unread_notifications_count =
      NotificationsRead.get_unread_notifications_count_for_specialist(specialist_id)

    conn
    |> render("unread_count.proto", %{
      unread_notifications_count: unread_notifications_count
    })
  end

  def mark_as_read(conn, params) do
    specialist_id = conn.assigns.current_specialist_id
    %{"id" => notification_id} = params

    :ok = NotificationsWrite.mark_specialist_notification_as_read(specialist_id, notification_id)

    unread_notifications_count =
      NotificationsRead.get_unread_notifications_count_for_specialist(specialist_id)

    conn
    |> render("unread_count.proto", %{unread_notifications_count: unread_notifications_count})
  end

  def mark_all_as_read(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    :ok = NotificationsWrite.mark_all_specialist_notifications_as_read(specialist_id)

    conn |> send_resp(200, "")
  end
end

defmodule Web.PanelApi.NotificationView do
  use Web, :view

  def render("index.proto", %{
        notifications: notifications,
        specialists_generic_data: specialists_generic_data,
        unread_notifications_count: unread_notifications_count,
        next_token: next_token
      }) do
    %Proto.Notifications.GetNotificationsResponse{
      notifications: Enum.map(notifications, &Web.View.Notifications.render_notification/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      unread_notifications_counter: unread_notifications_count,
      next_token: next_token
    }
  end

  def render("unread_count.proto", %{unread_notifications_count: unread_notifications_count}) do
    %Proto.Notifications.NotificationsCounterResponse{
      unread_notifications_counter: unread_notifications_count
    }
  end
end
