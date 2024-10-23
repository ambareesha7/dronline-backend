defmodule Web.View.GenericsTest do
  use Web.ConnCase, async: true

  describe "render_patient/1" do
    test "renders RelatedAdult for generic data with related_adult_patient_id present" do
      data = %Web.PatientGenericData{
        basic_info: %PatientProfile.BasicInfo{
          title: "MR",
          gender: "MALE",
          avatar_resource_path: "/test"
        },
        patient_id: 1,
        related_adult_patient_id: 2
      }

      assert %Proto.Generics.Patient{related_adult: %Proto.Generics.Patient.RelatedAdult{id: 2}} =
               Web.View.Generics.render_patient(data)
    end

    test "doesn't render RelatedAdult for generic data with related_adult_patient_id missing" do
      data = %Web.PatientGenericData{
        basic_info: %PatientProfile.BasicInfo{
          title: "MR",
          gender: "MALE",
          avatar_resource_path: "/test"
        },
        patient_id: 1,
        related_adult_patient_id: nil
      }

      assert %Proto.Generics.Patient{related_adult: nil} = Web.View.Generics.render_patient(data)
    end
  end
end
