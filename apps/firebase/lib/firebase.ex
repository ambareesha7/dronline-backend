defmodule Firebase do
  defdelegate dynamic_link(payload, options \\ []),
    to: Firebase.DynamicLinks,
    as: :generate

  defdelegate validate_authentication_token(token),
    to: Firebase.Authentication,
    as: :validate_token
end
