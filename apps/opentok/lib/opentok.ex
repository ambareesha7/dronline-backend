defmodule OpenTok do
  defdelegate create_session(record_id),
    to: OpenTok.Sessions,
    as: :create

  defdelegate create_session(),
    to: OpenTok.Sessions,
    as: :create

  defdelegate generate_session_token(session_id),
    to: OpenTok.Tokens,
    as: :generate

  defdelegate get_archive_information(archive_id),
    to: OpenTok.Archives,
    as: :get
end
