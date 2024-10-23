defmodule TeamsWeb.Router do
  use TeamsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticate do
    plug TeamsWeb.RequireTeamManagerPlug
  end

  scope "/teams/", TeamsWeb do
    pipe_through(:browser)

    get("/sign_in", SessionController, :new)
    post("/sign_in", SessionController, :create)
    delete("/sign_out", SessionController, :delete)
  end

  scope "/teams", TeamsWeb do
    pipe_through([:browser, :authenticate])

    get("/", TeamController, :index)
    post("/team_members", TeamController, :add_member)
    delete("/team_members/:specialist_id", TeamController, :remove_member)
  end
end
