defmodule Postgres.EctoType.Atom do
  @behaviour Ecto.Type

  def type, do: :string

  def cast(data) when is_binary(data), do: {:ok, String.to_existing_atom(data)}
  def cast(data) when is_atom(data), do: {:ok, data}
  def cast(_), do: :error

  def load(data), do: {:ok, String.to_existing_atom(data)}

  def dump(data), do: {:ok, to_string(data)}

  def embed_as(_format), do: :self

  def equal?(a, b), do: a == b
end
