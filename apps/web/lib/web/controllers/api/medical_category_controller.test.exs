defmodule Web.Api.MedicalCategoryControllerTest do
  use Web.ConnCase, async: true

  alias Proto.MedicalCategories.GetMedicalCategoriesResponse
  alias Proto.MedicalCategories.GetMedicalCategoryFeaturedDoctorsResponse
  alias Proto.MedicalCategories.GetMedicalCategoryResponse

  setup [:authenticate_patient]

  test "GET index", %{conn: conn} do
    %{id: category_id} =
      VisitsScheduling.Factory.insert(:medical_category,
        disabled: false,
        icon_url: "http://icon.url",
        name: "Allergology"
      )

    %Proto.MedicalCategories.GetMedicalCategoriesResponse{
      categories: [
        %Proto.MedicalCategories.MedicalCategory{
          id: ^category_id,
          name: "Allergology",
          icon_url: "http://icon.url",
          visit_type: :BOTH
        }
      ]
    } =
      conn
      |> get(medical_category_path(conn, :index))
      |> proto_response(200, GetMedicalCategoriesResponse)
  end

  test "GET show", %{conn: conn} do
    %{id: root_category_id} =
      VisitsScheduling.Factory.insert(:medical_category,
        disabled: false,
        icon_url: "http://icon.url",
        name: "Allergology"
      )

    %{id: category_id} =
      VisitsScheduling.Factory.insert(:medical_category,
        name: "Grass allergology",
        disabled: false,
        icon_url: "http://icon2.url",
        parent_category_id: root_category_id
      )

    conn = get(conn, medical_category_path(conn, :show, root_category_id))

    %Proto.MedicalCategories.GetMedicalCategoryResponse{
      category: %Proto.MedicalCategories.MedicalCategory{
        id: ^root_category_id,
        name: "Allergology",
        icon_url: "http://icon.url",
        visit_type: :BOTH
      },
      subcategories: [
        %Proto.MedicalCategories.MedicalCategory{
          id: ^category_id,
          name: "Grass allergology",
          icon_url: "http://icon2.url",
          visit_type: :BOTH
        }
      ]
    } = proto_response(conn, 200, GetMedicalCategoryResponse)
  end

  test "GET featured_doctors", %{conn: conn} do
    doctor = Authentication.Factory.insert(:verified_and_approved_external)
    basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor.id)

    medical_category = SpecialistProfile.Factory.insert(:medical_category, name: "Butthurt")
    _ = SpecialistProfile.update_medical_categories([medical_category.id], doctor.id)

    SpecialistProfile.Factory.insert(
      :location,
      specialist_id: doctor.id,
      coordinates: %{
        lat: 40.714268,
        lon: -74.005974
      }
    )

    # 8 miles from a Specialist - means Specialist is inside Patient's 100 mile range
    params = %{"lat" => "40.73566", "lon" => "-74.17237"}

    path = medical_category_featured_doctors_path(conn, :featured_doctors, medical_category.id)
    conn = get(conn, path, params)

    %GetMedicalCategoryFeaturedDoctorsResponse{featured_doctors: [fetched_doctor]} =
      proto_response(conn, 200, GetMedicalCategoryFeaturedDoctorsResponse)

    assert fetched_doctor.id == doctor.id
    assert fetched_doctor.first_name == basic_info.first_name
    assert fetched_doctor.last_name == basic_info.last_name
    assert fetched_doctor.avatar_url == basic_info.image_url

    assert fetched_doctor.medical_categories == [
             %Proto.Generics.Specialist.MedicalCategory{id: medical_category.id, name: "Butthurt"}
           ]
  end
end
