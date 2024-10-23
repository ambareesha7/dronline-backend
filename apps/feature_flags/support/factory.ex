defmodule FeatureFlags.Factory do
  defp flag_default_params do
    %{
      name: random_string(),
      enabled: true
    }
  end

  def insert(:flag, params) do
    params =
      flag_default_params()
      |> Map.merge(Enum.into(params, %{}))

    name = String.to_atom(params.name)

    if params[:enabled] do
      FunWithFlags.enable(name)
    else
      FunWithFlags.disable(name)
    end
  end

  defp random_string, do: System.unique_integer() |> to_string
end
