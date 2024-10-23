defmodule Postgres.Service do
  defmacro __using__(_opts) do
    quote do
      import Ecto.Query
      alias Postgres.Repo
    end
  end
end
