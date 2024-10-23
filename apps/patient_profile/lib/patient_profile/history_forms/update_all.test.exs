defmodule PatientProfile.HistoryForms.UpdateAllTest do
  use Postgres.DataCase, async: true

  alias Proto.PatientProfile.UpdateAllHistoryRequest

  describe "call/2" do
    test "insert provided forms if they are valid and they weren't provided before" do
      patient = PatientProfile.Factory.insert(:patient)

      proto = %UpdateAllHistoryRequest{
        allergy: Proto.Forms.Form.new(),
        social: Proto.Forms.Form.new()
      }

      assert {:ok, history_forms} = PatientProfile.HistoryForms.UpdateAll.call(proto, patient.id)
      assert %Proto.Forms.Form{fields: []} = history_forms.allergy
      assert %Proto.Forms.Form{fields: []} = history_forms.social
    end

    test "updates provided forms if they are valid" do
      patient = PatientProfile.Factory.insert(:patient)

      PatientProfile.Factory.insert(:history_forms,
        patient_id: patient.id
      )

      proto = %UpdateAllHistoryRequest{
        allergy: Proto.Forms.Form.new(),
        social: Proto.Forms.Form.new()
      }

      assert {:ok, history_forms} = PatientProfile.HistoryForms.UpdateAll.call(proto, patient.id)
      assert %Proto.Forms.Form{fields: []} = history_forms.allergy
      assert %Proto.Forms.Form{fields: []} = history_forms.social
    end

    test "returns {:error, changeset} when at least one of provided forms is invalid" do
      patient = PatientProfile.Factory.insert(:patient)

      PatientProfile.Factory.insert(:history_forms,
        patient_id: patient.id
      )

      proto = %UpdateAllHistoryRequest{
        allergy:
          Proto.Forms.Form.new(
            completed: false,
            fields: [
              Proto.Forms.FormField.new(
                uuid: "uuid",
                label: "label",
                value: {:integer, Proto.Forms.IntegerField.new()}
              )
            ]
          ),
        social: Proto.Forms.Form.new()
      }

      assert {:error, %Ecto.Changeset{}} =
               PatientProfile.HistoryForms.UpdateAll.call(proto, patient.id)
    end
  end
end
