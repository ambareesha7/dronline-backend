defmodule PatientProfile.HistoryForms.Validate do
  alias PatientProfile.HistoryForms.Helpers

  @spec validate_form({atom, Proto.Forms.Form.t()}) :: :ok | {:error, Ecto.Changeset.t()}
  def validate_form({_, form_proto}) do
    form_proto.fields
    |> Enum.reduce(%Ecto.Changeset{valid?: true}, fn field, changeset ->
      validate_field(changeset, field)
    end)
    |> case do
      %Ecto.Changeset{valid?: true} -> :ok
      changeset -> {:error, changeset}
    end
  end

  defp validate_field(changeset, field) do
    if Helpers.completed_form_field?(field) do
      validate_subform(changeset, field)
    else
      Ecto.Changeset.add_error(changeset, field.uuid, "This field is required")
    end
  end

  defp validate_subform(changeset, %Proto.Forms.FormField{value: {:select, select}}) do
    subform =
      case select.choice do
        nil -> []
        choice -> choice.subform
      end

    Enum.reduce(subform, changeset, fn field, changeset ->
      validate_field(changeset, field)
    end)
  end

  defp validate_subform(changeset, %Proto.Forms.FormField{value: {:multiselect, multiselect}}) do
    Enum.reduce(multiselect.choices, changeset, fn choice, changeset ->
      Enum.reduce(choice.subform, changeset, fn field, changeset ->
        validate_field(changeset, field)
      end)
    end)
  end

  defp validate_subform(changeset, _), do: changeset
end
