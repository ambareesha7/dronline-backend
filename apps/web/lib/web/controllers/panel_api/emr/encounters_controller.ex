defmodule Web.PanelApi.EMR.EncountersController do
  use Web, :controller

  alias EMR.Encounters.EncountersStats
  alias EMR.Encounters.SpecialistEncounters

  action_fallback Web.FallbackController

  plug Web.Plugs.RequireOnboarding
  plug Web.Plugs.AssignQuerySpecialistId, [] when action in [:index, :stats]

  def index(conn, params) do
    params = Map.update(params, "day_filter", nil, &parse_day_filter/1)

    {:ok, encounters, next_token} =
      SpecialistEncounters.get(conn.assigns.query_specialist_id, params)

    patient_ids = Enum.map(encounters, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    conn
    |> render("index.proto", %{
      encounters: encounters,
      patients_generic_data: patients_generic_data,
      next_token: next_token
    })
  end

  def show(conn, params) do
    timeline_id = params["id"]
    encounter = SpecialistEncounters.get_by_id(timeline_id)

    patient_generic_data =
      case encounter && encounter.patient_id do
        nil -> nil
        patient_id -> Web.PatientGenericData.get_by_id(patient_id)
      end

    conn
    |> render("show.proto", %{
      encounter: encounter,
      patient_generic_data: patient_generic_data
    })
  end

  def stats(conn, _params) do
    stats = EncountersStats.get_for_specialist(conn.assigns.query_specialist_id)

    conn
    |> render("stats.proto", %{
      scheduled: stats.scheduled,
      pending: stats.pending,
      canceled: stats.canceled,
      completed: stats.completed
    })
  end

  defp parse_day_filter(nil), do: nil
  defp parse_day_filter(day_filter), do: String.to_integer(day_filter)
end

defmodule Web.PanelApi.EMR.EncountersView do
  use Web, :view

  def render("index.proto", %{
        encounters: encounters,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      }) do
    %Proto.EMR.SpecialistEncountersResponse{
      encounters: Enum.map(encounters, &render_encounter/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1),
      next_token: next_token
    }
  end

  def render("show.proto", %{
        encounter: encounter,
        patient_generic_data: patient_generic_data
      }) do
    %Proto.EMR.SpecialistEncounterResponse{
      encounter: render_encounter(encounter),
      patient: Web.View.Generics.render_patient(patient_generic_data)
    }
  end

  def render("stats.proto", %{
        scheduled: scheduled,
        pending: pending,
        canceled: canceled,
        completed: completed
      }) do
    %Proto.EMR.SpecialistEncountersStatsResponse{
      scheduled: scheduled,
      pending: pending,
      canceled: canceled,
      completed: completed
    }
  end

  defp render_encounter(nil), do: nil

  defp render_encounter(encounter) do
    %{
      id: encounter.id,
      patient_id: encounter.patient_id,
      start_time: encounter.start_time,
      end_time: encounter.end_time,
      state:
        encounter.state
        |> then(fn
          nil -> :UNKNOWN_STATE
          state -> String.to_existing_atom(state)
        end)
        |> Proto.enum(Proto.EMR.SpecialistEncounter.State),
      type: Proto.enum(encounter.type, Proto.EMR.SpecialistEncounter.Type),
      us_board_request_id: encounter.us_board_request_id
    }
    |> Proto.validate!(Proto.EMR.SpecialistEncounter)
    |> Proto.EMR.SpecialistEncounter.new()
  end
end
