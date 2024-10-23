defmodule PatientProfile.Onboarding do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "patients" do
    field :onboarding_completed, :boolean

    timestamps()
  end

  @doc """
  Marks onboarding process for given patient_id as finished
  """
  @spec finished(pos_integer) :: :ok
  def finished(patient_id) do
    Onboarding
    |> where(id: ^patient_id)
    |> Repo.update_all(set: [onboarding_completed: true, updated_at: DateTime.utc_now()])
    |> case do
      {1, nil} ->
        :ok

      invalid ->
        _ = Sentry.Context.set_extra_context(%{invalid: invalid})
        raise "PatientProfile.Onboarding.finished/1 failure"
    end
  end
end
