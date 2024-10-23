defmodule UrgentCare.PatientsQueue do
  defdelegate add_to_queue(params), to: UrgentCare.PatientsQueue.Add, as: :call
  defdelegate remove_from_queue(params), to: UrgentCare.PatientsQueue.Remove, as: :call
  defdelegate cancel(params), to: UrgentCare.PatientsQueue.Cancel, as: :call
  defdelegate establish_call(params), to: UrgentCare.PatientsQueue.EstablishCall, as: :call
end
