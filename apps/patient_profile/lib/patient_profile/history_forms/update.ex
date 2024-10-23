defmodule PatientProfile.HistoryForms.Update do
  alias PatientProfile.HistoryForms
  alias PatientProfile.HistoryForms.Helpers
  alias Proto.Forms

  @spec call({atom, Forms.Form.t()}, pos_integer) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def call({form, form_proto}, patient_id) do
    form_proto = %Forms.Form{form_proto | completed: Helpers.completed_form?(form_proto)}
    params = %{form => Forms.Form.encode(form_proto)}

    with :ok <- HistoryForms.Validate.validate_form({form, form_proto}),
         {:ok, _history_forms} <- HistoryForms.update(params, patient_id) do
      {:ok, %{}} = PatientProfile.HistoryForms.Fetch.call(patient_id)
    end
  end
end
