defmodule Web.View.Dispatches do
  alias Triage.CurrentDispatch
  alias Triage.EndedDispatch
  alias Triage.OngoingDispatch
  alias Triage.PendingDispatch

  @open Proto.Dispatches.DetailedDispatch.Status.value(:OPEN)
  @ongoing Proto.Dispatches.DetailedDispatch.Status.value(:ONGOING)
  @ended Proto.Dispatches.DetailedDispatch.Status.value(:ENDED)

  def render_dispatch(%struct{} = dispatch)
      when struct in [CurrentDispatch, EndedDispatch, OngoingDispatch, PendingDispatch] do
    %Proto.Dispatches.Dispatch{
      request_id: dispatch.request_id,
      requested_at: dispatch.requested_at |> DateTime.to_unix(),
      patient_id: dispatch.patient_id,
      requester_id: dispatch.requester_id,
      record_id: dispatch.record_id,
      patient_location: dispatch.patient_location_address |> render_patient_location()
    }
  end

  def render_detailed_dispatch(%CurrentDispatch{} = dispatch) do
    %Proto.Dispatches.DetailedDispatch{
      dispatch: dispatch |> render_dispatch(),
      status: dispatch.status |> parse_status(),
      taken_at: dispatch.taken_at |> Web.View.Generics.render_datetime(),
      nurse_id: dispatch.nurse_id
    }
  end

  def render_detailed_dispatch(%EndedDispatch{} = dispatch) do
    %Proto.Dispatches.DetailedDispatch{
      dispatch: dispatch |> render_dispatch(),
      status: @ended,
      taken_at: dispatch.taken_at |> Web.View.Generics.render_datetime(),
      ended_at: dispatch.ended_at |> Web.View.Generics.render_datetime(),
      nurse_id: dispatch.nurse_id
    }
  end

  def render_patient_location(%Triage.PatientLocationAddress{} = address) do
    %Proto.Dispatches.PatientLocation{
      address: address |> Map.from_struct() |> Proto.Dispatches.PatientLocation.Address.new()
    }
  end

  # pattern for string-key based map
  def render_patient_location(%{"city" => _} = address) do
    keys = Proto.Dispatches.PatientLocation.Address |> Map.from_struct() |> Map.keys()

    %Proto.Dispatches.PatientLocation{
      address:
        Enum.reduce(keys, %Proto.Dispatches.PatientLocation.Address{}, fn key, acc ->
          %{acc | key => Map.get(address, to_string(key))}
        end)
    }
  end

  defp parse_status("PENDING"), do: @open
  defp parse_status("ONGOING"), do: @ongoing
end
