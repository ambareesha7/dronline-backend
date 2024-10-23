defmodule OpenTok.Helpers do
  def nonce, do: 16 |> :crypto.strong_rand_bytes() |> Base.encode16()
end
