defmodule Web.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import Web.Router.Helpers

      import ProtoResponse
      import Web.ConnHelpers

      use Web, :verified_routes

      @endpoint Web.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Postgres.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Postgres.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
