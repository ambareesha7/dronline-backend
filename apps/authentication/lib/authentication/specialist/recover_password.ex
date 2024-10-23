defmodule Authentication.Specialist.RecoverPassword do
  alias Authentication.Specialist

  @spec call(String.t(), String.t()) ::
          :ok | {:error, :unauthorized} | {:error, Ecto.Changeset.t()}
  def call(token, new_password) do
    with {:ok, specialist} <- Specialist.fetch_by_password_recovery_token(token),
         {:ok, %Specialist{}} <- Specialist.set_new_password(specialist, new_password) do
      :ok
    else
      {:error, :not_found} -> {:error, :unauthorized}
      {:error, %Ecto.Changeset{}} = validation_error -> validation_error
    end
  end
end
