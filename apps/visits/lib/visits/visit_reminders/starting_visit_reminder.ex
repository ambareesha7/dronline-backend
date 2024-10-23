defmodule Visits.StartingVisitReminder do
  use Postgres.Schema

  @schema "sent_visit_starting_reminders"

  schema @schema do
    field :visit_id, :binary_id
    field :visit_start_time, :integer

    timestamps()
  end
end
