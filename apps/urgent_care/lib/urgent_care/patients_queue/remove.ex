defmodule UrgentCare.PatientsQueue.Remove do
  use Postgres.Service
  alias Postgres.Repo

  def call(patient_id) do
    UrgentCare.PatientsQueue.Schema
    |> where(patient_id: ^patient_id)
    |> Repo.delete_all()

    broadcast_update()
  end

  def broadcast_update do
    Calls.ChannelBroadcast.broadcast(:patients_queue_update)
  end
end
