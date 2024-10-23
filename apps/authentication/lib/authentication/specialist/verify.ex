defmodule Authentication.Specialist.Verify do
  alias Authentication.Specialist

  @spec call(String.t()) :: {:ok, %Specialist{}} | {:error, :not_found}
  def call(verification_token) do
    with {:ok, specialist} <- Specialist.fetch_by_verification_token(verification_token),
         {:ok, specialist} <- Specialist.verify(specialist) do
      {:ok, specialist}
    end
  end
end
