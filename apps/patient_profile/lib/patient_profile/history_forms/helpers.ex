defmodule PatientProfile.HistoryForms.Helpers do
  alias Proto.Forms

  def completed_form?(form_proto) do
    Enum.all?(form_proto.fields, &completed_form_field?/1)
  end

  def completed_form_field?(%Forms.FormField{value: {_type, field}}),
    do: completed_field?(field)

  def completed_field?(%Forms.Select{choice: choice}), do: falsify_nil(choice)
  def completed_field?(%Forms.MultiSelect{choices: choices}), do: falsify_empty_array(choices)
  def completed_field?(%Forms.StringField{is_set: is_set}), do: is_set
  def completed_field?(%Forms.IntegerField{is_set: is_set}), do: is_set
  def completed_field?(%Forms.MonthField{is_set: is_set}), do: is_set

  def falsify_nil(nil), do: false
  def falsify_nil(_), do: true

  def falsify_empty_array([]), do: false
  def falsify_empty_array(_), do: true
end
