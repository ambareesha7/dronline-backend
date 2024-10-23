defmodule PatientProfile.HistoryForms.ValidateTest do
  use Postgres.DataCase, async: true

  describe "validate_form/1" do
    test "returns :ok when all subforms are valid" do
      form_proto = valid_form_proto_with_subforms()

      assert :ok = PatientProfile.HistoryForms.Validate.validate_form({:social, form_proto})
    end

    test "returns {:error, %Ecto.Changeset{}} when subform isn't valid" do
      form_proto = invalid_form_proto_with_subforms()

      assert {:error, changeset} =
               PatientProfile.HistoryForms.Validate.validate_form({:social, form_proto})

      assert %Ecto.Changeset{valid?: false, errors: [{"uuid2", _}]} = changeset
    end

    test "returns {:error, %Ecto.Changeset{}} when field isn't valid" do
      form_proto = invalid_field_form_proto()

      assert {:error, changeset} =
               PatientProfile.HistoryForms.Validate.validate_form({:social, form_proto})

      assert %Ecto.Changeset{valid?: false, errors: [{"uuid", _}]} = changeset
    end
  end

  defp valid_form_proto_with_subforms do
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
                Proto.Forms.Select.Option.new(
                  label: "label2",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "uuid2",
                      label: "label3",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                )
              ],
              choice:
                Proto.Forms.Select.Option.new(
                  label: "label2",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "uuid2",
                      label: "label3",
                      value: {:string, Proto.Forms.StringField.new(is_set: true)}
                    )
                  ]
                )
            )
          }
        )
      ]
    )
  end

  defp invalid_form_proto_with_subforms do
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
                Proto.Forms.Select.Option.new(
                  label: "label2",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "uuid2",
                      label: "label3",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                )
              ],
              choice:
                Proto.Forms.Select.Option.new(
                  label: "label2",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "uuid2",
                      label: "label3",
                      value: {:string, Proto.Forms.StringField.new(is_set: false)}
                    )
                  ]
                )
            )
          }
        )
      ]
    )
  end

  defp invalid_field_form_proto do
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
end
