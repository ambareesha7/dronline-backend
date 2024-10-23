defmodule Triage.Regions do
  @supported_regions ["united-arab-emirates-dubai"]

  @spec determine_region(%{required(:country) => String.t(), required(:city) => String.t()}) ::
          {:ok, String.t()} | {:error, String.t()}
  def determine_region(address) do
    region =
      "#{address.country} #{address.city}"
      |> String.replace(" ", "-")
      |> String.downcase()

    {:ok, region}
  end

  @spec validate_region_support(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_region_support(changeset) do
    Ecto.Changeset.validate_change(changeset, :region, fn _, region ->
      if region in @supported_regions do
        []
      else
        [_region: "triage units are not supported in selected region"]
      end
    end)
  end
end
