defmodule Postgres.Option do
  import Ecto.Query

  @doc """
  Universal helper for parsing limit option
  """
  def parse_limit(%{"limit" => ""}), do: 20
  def parse_limit(%{"limit" => limit}), do: String.to_integer(limit)
  def parse_limit(_), do: 20

  @doc """
  Universal helper for making query with next_token
  """
  def next_token(params, token_type \\ :id, order_type \\ :asc)

  def next_token(%{"next_token" => ""}, _, _), do: true

  def next_token(%{"next_token" => nt}, token_type, :asc),
    do: dynamic([m], field(m, ^token_type) >= ^nt)

  def next_token(%{"next_token" => nt}, token_type, :desc),
    do: dynamic([m], field(m, ^token_type) <= ^nt)

  def next_token(_, _, _), do: true

  @doc """
  Universal helper for encoding next_token to format which is suitable for passing as GET param
  """
  def decode_next_token(next_token) when next_token in ["", nil], do: %{}

  # sobelow_skip ["Misc.BinToTerm"]
  def decode_next_token(next_token) do
    next_token
    |> Base.url_decode64!()
    |> :erlang.binary_to_term([:safe])
  end

  @doc """
  Universal helper for decoding next_token
  """
  def encode_next_token(next_token) do
    next_token
    |> :erlang.term_to_binary()
    |> Base.url_encode64()
  end
end
