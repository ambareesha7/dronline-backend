defmodule Authentication.Admin.Login do
  alias Authentication.Admin

  @spec call(String.t(), String.t()) :: {:ok, %Authentication.Admin{}} | {:error, :unauthorized}
  def call(email, password) do
    email = String.downcase(email)

    with {:ok, admin} <- Admin.fetch_by_email(email),
         true <- Pbkdf2.verify_pass(password, admin.password_hash) do
      {:ok, admin}
    else
      {:error, :not_found} -> {:error, :unauthorized}
      false -> {:error, :unauthorized}
    end
  end
end
