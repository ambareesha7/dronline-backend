defmodule Proto do
  @doc """
  Checks if there's no typos in args passed to ProtobufModule.new/1

  ## Examples

      # valid
      iex> Proto.Authentication.LoginResponse.new(auth_token: "asdf")
      %Proto.Authentication.LoginResponse{auth_token: "asdf"}

      # bug (hard to spot)
      iex> Proto.Authentication.LoginResponse.new(autz_token: "asdf")
      %Proto.Authentication.LoginResponse{auth_token: ""}

      # bug (visible immediately)
      iex> %{autz_token: "asdf"}
      ...> |> Proto.validate!(Proto.Authentication.LoginResponse)
      ...> |> Proto.Authentication.LoginResponse.new()
      ** (RuntimeError) provided not-existing field :autz_token to Proto.Authentication.LoginResponse.new/1
  """
  if Mix.env() == :prod do
    def validate!(enumerable, _module), do: enumerable
  else
    def validate!(enumerable, module) do
      struct_keys = module |> struct() |> Map.from_struct() |> Map.keys()

      for {field, _value} <- enumerable,
          field not in struct_keys do
        raise "provided not-existing field #{inspect(field)} to #{inspect(module)}.new/1"
      end

      enumerable
    end
  end

  @doc """
  Transforms enum key to value if necessary

  ## Examples

      iex> :MR |> Proto.enum(Proto.Generics.Title)
      1

      iex > 1 |> Proto.enum(Proto.Generics.Title)
      1
  """
  def enum(nil = _value, _module), do: nil
  def enum(value, _module) when is_integer(value), do: value
  def enum(key, module) when is_atom(key), do: module.value(key)
end
