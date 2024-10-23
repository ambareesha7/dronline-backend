defmodule Web.Api.DoctorControllerTest do
  use Web.ConnCase, async: true

  alias EMR.SpecialistPatientConnections.SpecialistPatientConnection
  alias Proto.Doctors.GetDoctorsDetailsResponse
  alias Proto.Doctors.GetFavouriteProvidersResponse
  alias Proto.Doctors.GetFeaturedDoctorsResponse

  setup [:authenticate_patient]

  test "GET featured_doctors", %{conn: conn} do
    doctor = Authentication.Factory.insert(:verified_and_approved_external)
    basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor.id)
    Membership.Factory.insert(:accepted_subscription, specialist_id: doctor.id)

    medical_category = SpecialistProfile.Factory.insert(:medical_category, name: "Butthurt")
    _ = SpecialistProfile.update_medical_categories([medical_category.id], doctor.id)

    conn = get(conn, doctors_path(conn, :featured_doctors))

    %GetFeaturedDoctorsResponse{featured_doctors: [fetched_doctor]} =
      proto_response(conn, 200, GetFeaturedDoctorsResponse)

    assert fetched_doctor.id == doctor.id
    assert fetched_doctor.first_name == basic_info.first_name
    assert fetched_doctor.last_name == basic_info.last_name
    assert fetched_doctor.avatar_url == basic_info.image_url

    assert fetched_doctor.medical_categories == [
             %Proto.Generics.Specialist.MedicalCategory{id: medical_category.id, name: "Butthurt"}
           ]
  end

  test "GET featured_doctors with lat/lon", %{conn: conn} do
    doctor_platinum = Authentication.Factory.insert(:verified_and_approved_external)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor_platinum.id)

    Membership.Factory.insert(:accepted_subscription, specialist_id: doctor_platinum.id)

    SpecialistProfile.Factory.insert(
      :location,
      specialist_id: doctor_platinum.id,
      coordinates: %{
        lat: 40.714268,
        lon: -74.005974
      }
    )

    # 8 miles from a Specialist - means Specialist is inside Patient's 100 mile range
    params = %{"lat" => "40.73566", "lon" => "-74.17237"}

    conn = get(conn, doctors_path(conn, :featured_doctors), params)

    %GetFeaturedDoctorsResponse{
      featured_doctors: [
        %{
          id: id
        }
      ]
    } = proto_response(conn, 200, GetFeaturedDoctorsResponse)

    assert id == doctor_platinum.id
  end

  test "GET favourite_providers", %{conn: conn, current_patient: current_patient} do
    doctor = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor.id)

    medical_category = SpecialistProfile.Factory.insert(:medical_category, name: "Butthurt")
    _ = SpecialistProfile.update_medical_categories([medical_category.id], doctor.id)

    SpecialistPatientConnection.create(doctor.id, current_patient.id)

    conn = get(conn, doctors_path(conn, :favourite_providers))

    assert %GetFavouriteProvidersResponse{favourite_providers: [returned_doctor]} =
             proto_response(conn, 200, GetFavouriteProvidersResponse)

    assert returned_doctor.id == doctor.id
  end

  test "GET doctors_details", %{conn: conn} do
    doctor1 = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
    basic_info1 = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor1.id)
    medical_category = SpecialistProfile.Factory.insert(:medical_category, name: "Butthurt")
    _ = SpecialistProfile.update_medical_categories([medical_category.id], doctor1.id)

    doctor2 = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
    basic_info2 = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor2.id)

    params = %{"ids" => "#{doctor1.id},#{doctor2.id}"}
    conn = get(conn, doctors_path(conn, :doctors_details), params)

    assert %GetDoctorsDetailsResponse{doctors_details: doctors_details} =
             proto_response(conn, 200, GetDoctorsDetailsResponse)

    details1 = Enum.find(doctors_details, &(&1.id == doctor1.id))
    assert details1.first_name == basic_info1.first_name
    assert details1.last_name == basic_info1.last_name
    assert details1.avatar_url == basic_info1.image_url

    assert details1.medical_categories == [
             %Proto.Generics.Specialist.MedicalCategory{id: medical_category.id, name: "Butthurt"}
           ]

    details2 = Enum.find(doctors_details, &(&1.id == doctor2.id))
    assert details2.first_name == basic_info2.first_name
    assert details2.last_name == basic_info2.last_name
    assert details2.avatar_url == basic_info2.image_url
    assert details2.medical_categories == []
  end
end
