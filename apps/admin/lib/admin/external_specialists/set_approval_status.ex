defmodule Admin.ExternalSpecialists.SetApprovalStatus do
  alias Admin.ExternalSpecialists.ExternalSpecialist

  def call(specialist_id, status) do
    with {:ok, specialist} <- ExternalSpecialist.fetch_by_id(specialist_id),
         :ok <- onboarding_completed?(specialist),
         {:ok, specialist} <- ExternalSpecialist.set_approval_status(specialist, status) do
      {:ok, _job} = send_email(specialist, status)

      {:ok, specialist}
    end
  end

  defp onboarding_completed?(%{onboarding_completed_at: nil}),
    do: {:error, "Specialist didn't complete onboarding process."}

  defp onboarding_completed?(_), do: :ok

  def send_email(specialist, "VERIFIED") do
    %{
      type: "EXTERNAL_SPECIALIST_APPROVAL",
      specialist_email: specialist.email
    }
    |> Mailers.MailerJobs.new()
    |> Oban.insert()
  end

  def send_email(specialist, "REJECTED") do
    %{
      type: "EXTERNAL_SPECIALIST_REJECTION",
      specialist_email: specialist.email
    }
    |> Mailers.MailerJobs.new()
    |> Oban.insert()
  end
end
