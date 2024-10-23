defmodule Upload.Signer do
  defmodule Params do
    @fields [:verb, :md5_digest, :content_type, :extension, :expires, :resource]

    @enforce_keys @fields
    defstruct @fields
  end

  def sign_url(%Upload.Signer.Params{} = signer_params) do
    signature =
      [
        signer_params.verb,
        signer_params.md5_digest,
        signer_params.content_type,
        signer_params.expires,
        signer_params.extension,
        signer_params.resource
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
      |> generate_signature()

    url = "#{Application.get_env(:upload, :base_url)}#{signer_params.resource}"

    qs =
      %{
        "GoogleAccessId" => Application.get_env(:upload, :client_email),
        "Expires" => signer_params.expires,
        "Signature" => signature
      }
      |> URI.encode_query()

    Enum.join([url, "?", qs])
  end

  defp generate_signature(string) do
    private_key = get_private_key()

    string
    |> :public_key.sign(:sha256, private_key)
    |> Base.encode64()
  end

  defp get_private_key do
    private_key = Application.get_env(:upload, :private_key)

    private_key
    |> String.replace("\\n", "\n")
    |> :public_key.pem_decode()
    |> hd()
    |> :public_key.pem_entry_decode()
  end
end
