defmodule Visits.UpcomingVisitReminder do
  use Postgres.Schema

  @schema "sent_visit_reminders_v2"

  schema @schema do
    field :visit_id, :binary_id
    field :visit_start_time, :integer

    timestamps()
  end
end
