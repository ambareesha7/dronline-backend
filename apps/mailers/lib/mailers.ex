defmodule Mailers do
  def send_email(params) do
    params
    |> Mailers.MailerJobs.new()
    |> Oban.insert()
  end
end
