defmodule PatientProfile.HistoryForms.UpdateAll do
  alias PatientProfile.HistoryForms
  alias PatientProfile.HistoryForms.Helpers
  alias Proto.Forms

  @forms [:allergy, :family, :immunization, :medical, :social, :surgical]

  @spec call(map, pos_integer) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def call(proto, patient_id) do
    with %{} = params <- validate_and_encode_forms(proto),
         {:ok, _history_forms} <- HistoryForms.update(params, patient_id) do
      {:ok, %{}} = PatientProfile.HistoryForms.Fetch.call(patient_id)
    end
  end

  defp validate_and_encode_forms(proto) do
    Enum.reduce_while(@forms, %{}, &validate_and_encode_form(&1, &2, proto))
  end

  defp validate_and_encode_form(form, acc, proto) when is_nil(:erlang.map_get(form, proto)),
    do: {:cont, acc}

  defp validate_and_encode_form(form, acc, proto) do
    form_proto = Map.get(proto, form)
    form_proto = %Forms.Form{form_proto | completed: Helpers.completed_form?(form_proto)}

    case HistoryForms.Validate.validate_form({form, form_proto}) do
      :ok -> {:cont, Map.put(acc, form, Forms.Form.encode(form_proto))}
      {:error, changeset} -> {:halt, {:error, changeset}}
    end
  end
end
