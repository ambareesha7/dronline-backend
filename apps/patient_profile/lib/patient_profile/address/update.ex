defmodule PatientProfile.Address.Update do
  alias PatientProfile.Address

  alias PatientProfile.Onboarding

  @spec call(map, pos_integer) ::
          {:ok, %Address{}} | {:error, Ecto.Changeset.t()}
  def call(params, patient_id) do
    with {:ok, %Address{} = address} <- Address.update(params, patient_id) do
      :ok = Onboarding.finished(patient_id)

      {:ok, address}
    end
  end
end
