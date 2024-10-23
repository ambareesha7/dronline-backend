defmodule MembershipMock.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    children =
      case Application.get_env(:membership_mock, :env) do
        :test ->
          children

        _ ->
          children ++
            [
              MembershipMock.EndTrialsScheduler
            ]
      end

    opts = [strategy: :one_for_one, name: Visits.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
