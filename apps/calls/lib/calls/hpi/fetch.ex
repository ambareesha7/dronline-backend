defmodule Calls.HPI.Fetch do
  @spec call(pos_integer) :: {:ok, %EMR.HPI{}}
  def call(patient_id) do
    {:ok, record} = EMR.fetch_or_create_automatic_record(patient_id)

    EMR.fetch_hpi(patient_id, record.id)
  end
end
