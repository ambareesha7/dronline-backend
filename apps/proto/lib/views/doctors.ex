defmodule Proto.DoctorsView do
  use Proto.View

  # def render("featured_doctor.proto", %{featured_doctor: featured_doctor}) do
  #   %{
  #     id: featured_doctor.id,
  #     first_name: featured_doctor.first_name,
  #     last_name: featured_doctor.last_name,
  #     avatar_url: featured_doctor.avatar_url,
  #     categories: featured_doctor.categories,
  #     package_type: featured_doctor.package_type |> Proto.Doctors.PackageType.value()
  #   }
  #   |> Proto.validate!(Proto.Doctors.FeaturedDoctor)
  #   |> Proto.Doctors.FeaturedDoctor.new()
  # end

  # def render("favourite_provider.proto", %{favourite_provider: favourite_provider}) do
  #   %{
  #     id: favourite_provider.id,
  #     first_name: favourite_provider.first_name,
  #     last_name: favourite_provider.last_name,
  #     avatar_url: favourite_provider.avatar_url,
  #     categories: favourite_provider.categories,
  #     package_type: favourite_provider.package_type |> Proto.Doctors.PackageType.value()
  #   }
  #   |> Proto.validate!(Proto.Doctors.FeaturedDoctor)
  #   |> Proto.Doctors.FeaturedDoctor.new()
  # end

  def render("doctor_details.proto", %{doctor_details: doctor_details}) do
    %{
      id: doctor_details.id,
      first_name: doctor_details.first_name,
      last_name: doctor_details.last_name,
      avatar_url: doctor_details.avatar_url,
      categories: doctor_details.categories,
      package_type: doctor_details.package_type |> Proto.Doctors.PackageType.value()
    }
    |> Proto.validate!(Proto.Doctors.DoctorDetails)
    |> Proto.Doctors.DoctorDetails.new()
  end
end
