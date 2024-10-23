defmodule Web.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest

      @endpoint Web.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Postgres.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Postgres.Repo, {:shared, self()})
    end

    :ok
  end
end
