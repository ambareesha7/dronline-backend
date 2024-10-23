defmodule OpenTokMock do
  def create_session(_record_id), do: {:ok, "session_id"}
  def create_session, do: {:ok, "session_id"}
end
