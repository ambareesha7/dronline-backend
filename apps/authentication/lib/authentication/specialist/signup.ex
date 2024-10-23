defmodule Authentication.Specialist.Signup do
  alias Authentication.Specialist

  alias Postgres.Repo

  @spec call(String.t(), String.t()) ::
          :ok | {:error, Ecto.Changeset.t() | :email_taken}
  def call(email, password) do
    email = String.downcase(email)

    with {:ok, params} <- prepare_params(email, password),
         {:ok, specialist} <- Specialist.register(params),
         :ok <- send_verification_link(specialist) do
      :ok
    else
      # if someone wanted to register with existing email
      # inform owner of this situation
      {:error, :email_taken} ->
        {:ok, specialist} = Repo.fetch_by(Specialist, email: email)

        :ok = send_warning_info(specialist)

      error ->
        error
    end
  end

  @spec prepare_params(String.t(), String.t()) :: {:ok, map}
  defp prepare_params(email, password) do
    params = %{
      email: email,
      password: password,
      type: "EXTERNAL"
    }

    {:ok, params}
  end

  @spec send_verification_link(%Specialist{}) :: :ok
  defp send_verification_link(specialist) do
    {:ok, _job} =
      %{
        type: "SPECIALIST_VERIFICATION_LINK",
        specialist_email: specialist.email,
        specialist_type: specialist.type,
        verification_token: specialist.verification_token
      }
      |> Mailers.MailerJobs.new()
      |> Oban.insert()

    :ok
  end

  @spec send_warning_info(%Specialist{}) :: :ok
  defp send_warning_info(specialist) do
    with {:ok, _job} <-
           %{
             type: "SPECIALIST_SIGNUP_WARNING",
             specialist_email: specialist.email
           }
           |> Mailers.MailerJobs.new()
           |> Oban.insert() do
      :ok
    end
  end
end
