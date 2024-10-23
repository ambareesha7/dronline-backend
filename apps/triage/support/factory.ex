defmodule Triage.Factory do
  defp viatals_default_params do
    %{
      weight: 183,
      height: 80,
      systolic: 120,
      diastolic: 60,
      pulse: 80,
      ekg_file_url: "http://example.com/ekg.png"
    }
  end

  def insert(kind, params \\ %{})

  def insert(:vitals, params) do
    params = Map.merge(viatals_default_params(), Enum.into(params, %{}))

    {:ok, vitals} =
      Triage.Vitals.create(params.patient_id, params.timeline_id, params.nurse_id, params)

    vitals
  end
end
