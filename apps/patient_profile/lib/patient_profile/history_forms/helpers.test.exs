defmodule PatientProfile.HistoryForms.HelpersTest do
  use Postgres.DataCase, async: true

  alias PatientProfile.HistoryForms.Helpers

  describe "Select" do
    test "should be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :select,
                Proto.Forms.Select.new(
                  options: [
                    Proto.Forms.Select.Option.new(label: "Option1"),
                    Proto.Forms.Select.Option.new(label: "Option2")
                  ],
                  choice: Proto.Forms.Select.Option.new(label: "Option1")
                )
              }
            )
          ]
        )

      assert Helpers.completed_form?(proto_form)
    end

    test "shouldn't be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :select,
                Proto.Forms.Select.new(
                  options: [
                    Proto.Forms.Select.Option.new(label: "Option1"),
                    Proto.Forms.Select.Option.new(label: "Option2")
                  ],
                  choice: nil
                )
              }
            )
          ]
        )

      refute Helpers.completed_form?(proto_form)
    end
  end

  describe "MultiSelect" do
    test "should be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :multiselect,
                Proto.Forms.MultiSelect.new(
                  options: [
                    Proto.Forms.MultiSelect.Option.new(label: "Option1"),
                    Proto.Forms.MultiSelect.Option.new(label: "Option2")
                  ],
                  choices: [Proto.Forms.MultiSelect.Option.new(label: "Option1")]
                )
              }
            )
          ]
        )

      assert Helpers.completed_form?(proto_form)
    end

    test "shouldn't be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :multiselect,
                Proto.Forms.MultiSelect.new(
                  options: [
                    Proto.Forms.MultiSelect.Option.new(label: "Option1"),
                    Proto.Forms.MultiSelect.Option.new(label: "Option2")
                  ],
                  choice: []
                )
              }
            )
          ]
        )

      refute Helpers.completed_form?(proto_form)
    end
  end

  describe "StringField" do
    test "should be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :string,
                Proto.Forms.StringField.new(value: "set", is_set: true)
              }
            )
          ]
        )

      assert Helpers.completed_form?(proto_form)
    end

    test "shouldn't be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :string,
                Proto.Forms.StringField.new(is_set: false)
              }
            )
          ]
        )

      refute Helpers.completed_form?(proto_form)
    end
  end

  describe "IntegerField" do
    test "should be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :integer,
                Proto.Forms.IntegerField.new(value: 1337, is_set: true)
              }
            )
          ]
        )

      assert Helpers.completed_form?(proto_form)
    end

    test "shouldn't be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :integer,
                Proto.Forms.IntegerField.new(is_set: false)
              }
            )
          ]
        )

      refute Helpers.completed_form?(proto_form)
    end
  end

  describe "MonthField" do
    test "should be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :month,
                Proto.Forms.MonthField.new(value: 11, is_set: true)
              }
            )
          ]
        )

      assert Helpers.completed_form?(proto_form)
    end

    test "shouldn't be completed" do
      proto_form =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              label: "Test",
              value: {
                :month,
                Proto.Forms.MonthField.new(is_set: false)
              }
            )
          ]
        )

      refute Helpers.completed_form?(proto_form)
    end
  end
end
