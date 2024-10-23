defmodule Authentication.Specialist.SendPasswordRecovery do
  alias Authentication.Specialist

  @spec call(String.t()) :: :ok
  def call(email) do
    email = String.downcase(email)

    with {:ok, specialist} <- Specialist.fetch_by_verified_email(email),
         {:ok, specialist} <- Specialist.create_password_recovery_token(specialist) do
      {:ok, _job} =
        %{
          type: "SPECIALIST_PASSWORD_RECOVERY_LINK",
          specialist_email: specialist.email,
          password_recovery_token: specialist.password_recovery_token
        }
        |> Mailers.MailerJobs.new()
        |> Oban.insert()

      :ok
    else
      {:error, :not_found} -> :ok
    end
  end
end
