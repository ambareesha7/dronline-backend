defmodule Authentication.Specialist.Login do
  alias Authentication.Specialist

  @spec call(String.t(), String.t()) ::
          {:ok, map} | {:error, :unauthorized} | {:error, String.t()}
  def call(email, password) do
    email = String.downcase(email)

    with {:ok, specialist} <- Specialist.fetch_by_email(email),
         password_hash = specialist.password_hash,
         {:checkpw, true} <- {:checkpw, Pbkdf2.verify_pass(password, password_hash)},
         {:specialist, %{verified: true}} <- {:specialist, specialist} do
      {:ok, parse_result(specialist)}
    else
      {:error, :not_found} ->
        {:error, :unauthorized}

      {:checkpw, false} ->
        {:error, :unauthorized}

      {:specialist, %{verified: false}} ->
        {:error,
         "You have not verified your email address. Please check your inbox to verify your account"}
    end
  end

  defp parse_result(specialist) do
    %{
      auth_token: specialist.auth_token,
      type: specialist.type |> String.to_existing_atom(),
      package_type: specialist.package_type
    }
  end
end
