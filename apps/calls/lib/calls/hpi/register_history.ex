defmodule Calls.HPI.RegisterHistory do
  @spec call(pos_integer, Proto.Forms.Form.t()) :: {:ok, %EMR.HPI{}}
  def call(patient_id, form) do
    {:ok, record} = EMR.fetch_or_create_automatic_record(patient_id)

    EMR.register_hpi_history(patient_id, record.id, form)
  end
end
