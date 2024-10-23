defmodule Calls.ChannelBroadcastMock do
  def broadcast(_), do: :ok
  def push(_), do: :ok
end

defmodule CallsMock do
  def call_gp_as_nurse(_), do: :ok
  def cancel_call_to_gp_as_nurse(_), do: :ok
  def answer_call_from_nurse_as_gp(_), do: :ok
  def accept_doctor_category_invitation(_), do: :ok
end
