defmodule Postgres.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias Postgres.Repo

      @timestamps_opts [type: :naive_datetime_usec]
    end
  end
end
