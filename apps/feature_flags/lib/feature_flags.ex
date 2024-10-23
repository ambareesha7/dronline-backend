defmodule FeatureFlags do
  # sobelow_skip ["DOS.StringToAtom"]
  def enabled?(flag_name) do
    flag_name
    |> String.to_atom()
    |> FunWithFlags.enabled?()
  end

  # sobelow_skip ["DOS.StringToAtom"]
  def enable(flag_name) do
    flag_name
    |> String.to_atom()
    |> FunWithFlags.enable()
  end

  # sobelow_skip ["DOS.StringToAtom"]
  def disable(flag_name) do
    flag_name
    |> String.to_atom()
    |> FunWithFlags.disable()
  end
end
