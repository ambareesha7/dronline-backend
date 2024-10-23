defmodule PatientProfile.HistoryForms.UpdateTest do
  use Postgres.DataCase, async: true

  test "returns {:error, changeset} when validation fails" do
    patient = PatientProfile.Factory.insert(:patient)
    _history_forms = PatientProfile.Factory.insert(:history_forms, patient_id: patient.id)

    form_proto = invalid_form_proto()

    assert {:error, %Ecto.Changeset{}} =
             PatientProfile.HistoryForms.Update.call({:social, form_proto}, patient.id)
  end

  test "returns {:ok, map} when succeeds" do
    patient = PatientProfile.Factory.insert(:patient)
    _history_forms = PatientProfile.Factory.insert(:history_forms, patient_id: patient.id)

    form_proto = valid_form_proto()

    assert {:ok, _map} =
             PatientProfile.HistoryForms.Update.call({:social, form_proto}, patient.id)
  end

  defp invalid_form_proto do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "uuid",
          label: "label",
          value: {
            :select,
            Proto.Forms.Select.new(
              options: [
                Proto.Forms.Select.Option.new(label: "label2")
              ]
            )
          }
        )
      ]
    )
  end

  defp valid_form_proto do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "uuid",
          label: "label",
          value: {
            :select,
            Proto.Forms.Select.new(
              options: [
                Proto.Forms.Select.Option.new(label: "label2")
              ],
              choice: Proto.Forms.Select.Option.new(label: "label2")
            )
          }
        )
      ]
    )
  end
end
