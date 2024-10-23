defmodule PatientProfile.Factory do
  defp random_string, do: System.unique_integer() |> to_string()

  def insert(kind, params \\ %{})

  def insert(:address, params) do
    default = %{
      street: random_string(),
      home_number: random_string(),
      zip_code: random_string(),
      city: random_string(),
      country: random_string(),
      neighborhood: random_string()
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, address} = PatientProfile.Address.Update.call(params, params[:patient_id])

    address
  end

  def insert(:basic_info, params) do
    default = %{
      title: "MR",
      gender: "MALE",
      first_name: random_string(),
      last_name: random_string(),
      birth_date: ~D[1992-11-30],
      email: random_string()
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, basic_info} = PatientProfile.BasicInfo.update(params, params[:patient_id])

    basic_info
  end

  def insert(:bmi, params) do
    default = %{
      height: 170,
      weight: 60
    }

    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, bmi} = PatientProfile.BMI.update(params, params[:patient_id])

    bmi
  end

  def insert(:history_forms, params) do
    params = Enum.into(params, %{})

    {:ok, history_forms} = PatientProfile.HistoryForms.update(params, params[:patient_id])

    history_forms
  end

  def insert(:patient, params) do
    phone_number = "+48#{Enum.random(100_000_000..999_999_999)}"

    default = %{phone_number: phone_number}
    params = Map.merge(default, Enum.into(params, %{}))

    {:ok, patient} = PatientProfile.Schema.create(params[:phone_number])

    patient
  end

  def valid_review_of_system_form do
    template = PatientProfile.ReviewOfSystem.Template.template()

    %{template | fields: Enum.map(template.fields, &add_answer/1), completed: true}
  end

  defp add_answer(%{value: {:multiselect, multiselect}} = field) do
    %{
      field
      | value:
          {:multiselect,
           %{multiselect | choices: Enum.take_random(multiselect.options, Enum.random(0..3))}}
    }
  end
end
