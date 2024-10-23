defmodule PatientProfile.ReviewOfSystem.EctoType.Form do
  @behaviour Ecto.Type

  def type, do: :binary

  def cast(%Proto.Forms.Form{} = form), do: {:ok, form}
  def cast(_), do: :error

  def load(data), do: {:ok, Proto.Forms.Form.decode(data)}

  def dump(%Proto.Forms.Form{} = form), do: {:ok, Proto.Forms.Form.encode(form)}
  def dump(_), do: :error

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
