defmodule Authentication.Specialist.PasswordChange.Create do
  alias Authentication.Specialist
  alias Authentication.Specialist.PasswordChange

  def call(specialist_id, new_password) do
    with {:ok, password_change} <- PasswordChange.create(specialist_id, new_password),
         {:ok, specialist} <- Specialist.fetch_by_id(specialist_id) do
      %{
        type: "SPECIALIST_PASSWORD_CHANGE_LINK",
        specialist_email: specialist.email,
        password_change_confirmation_token: password_change.confirmation_token
      }
      |> Mailers.MailerJobs.new()
      |> Oban.insert()
    end
  end
end
