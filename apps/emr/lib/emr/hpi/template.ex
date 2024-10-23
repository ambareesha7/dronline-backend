defmodule EMR.HPI.Template do
  def template(:coronavirus) do
    Proto.Forms.Form.new(
      fields: [
        Proto.Forms.FormField.new(
          uuid: "786d4cd3-119e-4634-b95d-44e3499dc117",
          label: "Do you have a temperature?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "03d3bd29-ca39-4cb9-8d77-ddd3dd99e87d",
          label: "Do you have a runny noise?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "eed72972-62aa-46f4-9a3a-6d6fae884bc5",
          label: "Do you have a headache?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "44311ac1-691e-41d0-b293-1c393e018922",
          label: "Do you have a cough/soar throat?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "1ea4619d-7e19-4de9-9a56-ae0d99e2a2af",
          label: "Any body ache?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "3ae67050-67b1-4aac-9207-2a110a094cb9",
          label: "Shortness of breathe?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "9d397af3-bae3-49cb-ba60-b8453f24358b",
          label: "Did you travel outside the country?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "5647df5a-4cad-4dc0-9bc9-b5163cc8743f",
          label: "Have you been in contact with anyone who has been infected with Covid-19?",
          value: {:string, Proto.Forms.StringField.new()}
        )
      ]
    )
  end

  def template(:default) do
    Proto.Forms.Form.new(
      fields: [
        Proto.Forms.FormField.new(
          uuid: "1ba6a2fd-ac5c-4ab4-99bb-d3cace4d4c36",
          label: "Why are you seeing the doctor today?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "811bc643-9128-4205-93ab-ecbe12f59f90",
          label: "When did this problem start?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "ed043a35-cbb5-45de-b997-f324fc364d1a",
          label: "Any changes in this problem?",
          value:
            {:select,
             Proto.Forms.Select.new(
               options: [
                 Proto.Forms.Select.Option.new(
                   label: "Yes",
                   uuid: "a8ca4b28-2202-460a-ae06-46b67ecd0c6f"
                 ),
                 Proto.Forms.Select.Option.new(
                   label: "No",
                   uuid: "7bf71ec5-f178-4b9c-a97d-e6f92441f6a2"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "f3a15ee4-4b0d-42d9-ac1f-a1f8c5db5a7f",
          label: "Did you injure yourself at work?",
          value:
            {:select,
             Proto.Forms.Select.new(
               options: [
                 Proto.Forms.Select.Option.new(
                   label: "Yes",
                   uuid: "0bf0744d-e229-47d7-833e-3e37a92207b7"
                 ),
                 Proto.Forms.Select.Option.new(
                   label: "No",
                   uuid: "0084039c-1e18-45dc-95c8-a5a8652d3718"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "e51afb4a-0716-406a-a12c-aa4433e86f75",
          label: "What makes this condition improve?",
          value: {:string, Proto.Forms.StringField.new()}
        ),
        Proto.Forms.FormField.new(
          uuid: "ff2e8f34-417e-4ec7-81d6-991580fa56f0",
          label: "What makes this condition worse?",
          value: {:string, Proto.Forms.StringField.new()}
        )
      ]
    )
  end

  # @doc """
  # Adds missing uuids to given form based on template.
  #
  # It's meant to be used in console
  # """
  # def add_missing_uuids(hpi_form) do
  #   fields_map = template().fields |> Map.new(&{&1.label, &1})
  #
  #   %{hpi_form | fields: Enum.map(hpi_form.fields, &transform_field(&1, fields_map))}
  # end
  #
  # defp transform_field(%{value: {:string, _}} = field, fields_map) do
  #   %{field | uuid: fields_map[field.label].uuid}
  # end
  #
  # defp transform_field(%{value: {:select, select}} = field, fields_map) do
  #   field_template = fields_map[field.label]
  #
  #   %{
  #     field
  #     | uuid: field_template.uuid,
  #       value: {:select, transform_select(select, field_template)}
  #   }
  # end
  #
  # defp transform_select(select, field_template) do
  #   %{value: {:select, select_template}} = field_template
  #   options_map = select_template.options |> Map.new(&{&1.label, &1})
  #
  #   %{
  #     select
  #     | choice: %{select.choice | uuid: options_map[select.choice.label].uuid},
  #       options:
  #         Enum.map(select.options, fn option ->
  #           %{option | uuid: options_map[option.label].uuid}
  #         end)
  #   }
  # end

  # @doc """
  # Updates form based on uuids
  #
  # It's meant to be used in console
  # """
  # def merge_form_with_template(hpi_form) do
  #   fields_map = template().fields |> Map.new(&{&1.uuid, &1})
  #
  #   %{hpi_form | fields: Enum.map(hpi_form.fields, &transform_field(&1, fields_map))}
  # end
  #
  # defp transform_field(%{value: {:string, _}} = field, fields_map) do
  #   %{field | label: fields_map[field.uuid].label}
  # end
  #
  # defp transform_field(%{value: {:select, select}} = field, fields_map) do
  #   field_template = fields_map[field.uuid]
  #
  #   %{
  #     field
  #     | label: field_template.label,
  #       value: {:select, transform_select(select, field_template)}
  #   }
  # end
  #
  # defp transform_select(select, field_template) do
  #   %{value: {:select, select_template}} = field_template
  #   options_map = select_template.options |> Map.new(&{&1.uuid, &1})
  #
  #   %{
  #     select
  #     | choice: %{select.choice | label: options_map[select.choice.uuid].label},
  #       options:
  #         Enum.map(select.options, fn option ->
  #           %{option | label: options_map[option.uuid].label}
  #         end)
  #   }
  # end
end
