defmodule Postgres.EctoType.Term do
  @moduledoc """
  Type used to store any erlang term as binary
  """

  @behaviour Ecto.Type
  def type, do: :binary

  def cast(term), do: {:ok, term}

  # sobelow_skip ["Misc.BinToTerm"]
  def load(binary) do
    {:ok, :erlang.binary_to_term(binary, [:safe])}
  end

  def dump(term), do: {:ok, :erlang.term_to_binary(term)}

  def embed_as(_), do: :self

  def equal?(value1, value2) do
    with {:ok, term1} <- cast(value1),
         {:ok, term2} <- cast(value2) do
      term1 == term2
    else
      _ -> false
    end
  end
end
