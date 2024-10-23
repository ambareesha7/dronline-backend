defmodule Web.Parsers.EMR.VitalsParams do
  def to_map_params(%Proto.EMR.VitalsParams{} = proto) do
    %{
      height: proto.height.value,
      weight: proto.weight.value,
      blood_pressure_systolic: proto.blood_pressure_systolic,
      blood_pressure_diastolic: proto.blood_pressure_diastolic,
      pulse: proto.pulse,
      respiratory_rate: proto.respiratory_rate,
      body_temperature: proto.body_temperature,
      physical_exam: proto.physical_exam
    }
  end
end
