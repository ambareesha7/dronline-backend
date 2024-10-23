defmodule Postgres.Notifications do
  def listen(channel), do: Postgrex.Notifications.listen(__MODULE__, channel)

  def unlisten(ref), do: Postgrex.Notifications.unlisten(__MODULE__, ref)
end
