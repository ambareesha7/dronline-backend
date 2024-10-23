defmodule Web.Plugs.RequireOnboarding do
  use Web, :plug

  @scopes ["NURSE", "GP", "EXTERNAL"]

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    Conductor.Plugs.Authorize.call(conn, @scopes)
  end
end
