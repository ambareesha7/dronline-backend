defmodule Web.Parsers.SpecialistProfile.Bio do
  @spec to_map_params(Proto.SpecialistProfile.Bio.t()) :: map
  def to_map_params(%Proto.SpecialistProfile.Bio{} = proto) do
    %{
      description: proto.description,
      education: Enum.map(proto.education, &Map.from_struct/1),
      work_experience: Enum.map(proto.work_experience, &Map.from_struct/1)
    }
  end
end
