defmodule Web.Api.Specialists.InsuranceProvidersControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.GetInsuranceProvidersV2
  alias Proto.SpecialistProfileV2.InsuranceProvidersEntryV2
  alias Proto.SpecialistProfileV2.MatchingInsuranceProviderV2

  describe "GET show" do
    setup [:authenticate_patient]

    setup %{current_patient: current_patient} do
      PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)
      specialist = Authentication.Factory.insert(:specialist)
      country = Postgres.Factory.insert(:country, [])

      insurance_provider1 =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      insurance_provider2 =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      {:ok,
       current_patient: current_patient,
       insurance_provider1: insurance_provider1,
       insurance_provider2: insurance_provider2,
       specialist: specialist}
    end

    test "returns list of insurance providers records with matching provider between patient and specialist",
         %{
           conn: conn,
           current_patient: current_patient,
           insurance_provider1: insurance_provider1,
           insurance_provider2: insurance_provider2,
           specialist: specialist
         } do
      insurance_provider1_id = insurance_provider1.id

      _patient_insurance =
        Insurance.set_patient_insurance(
          %{provider_id: insurance_provider1.id, member_id: "member_id"},
          current_patient.id
        )

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist.id,
        [
          insurance_provider1.id,
          insurance_provider2.id
        ]
      )

      conn = get(conn, specialists_insurance_providers_path(conn, :index, specialist))

      assert %GetInsuranceProvidersV2{
               insurance_providers: [
                 %InsuranceProvidersEntryV2{name: "provider_name1"},
                 %InsuranceProvidersEntryV2{name: "provider_name2"}
               ],
               matching_provider: %MatchingInsuranceProviderV2{
                 id: ^insurance_provider1_id,
                 name: "provider_name1"
               }
             } = proto_response(conn, 200, GetInsuranceProvidersV2)
    end

    test "returns list of insurance providers records when there is no matching provider between patient and specialist",
         %{
           conn: conn,
           current_patient: current_patient,
           insurance_provider1: insurance_provider1,
           insurance_provider2: insurance_provider2,
           specialist: specialist
         } do
      _patient_insurance =
        Insurance.set_patient_insurance(
          %{provider_id: insurance_provider2.id, member_id: "member_id"},
          current_patient.id
        )

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist.id,
        [
          insurance_provider1.id
        ]
      )

      conn = get(conn, specialists_insurance_providers_path(conn, :index, specialist))

      assert %GetInsuranceProvidersV2{
               insurance_providers: [
                 %InsuranceProvidersEntryV2{name: "provider_name1"}
               ],
               matching_provider: %MatchingInsuranceProviderV2{id: 0, name: ""}
             } = proto_response(conn, 200, GetInsuranceProvidersV2)
    end

    test "returns list of insurance providers records when patient doesn't have any provider", %{
      conn: conn,
      insurance_provider1: insurance_provider1,
      insurance_provider2: insurance_provider2,
      specialist: specialist
    } do
      SpecialistProfile.Specialist.update_insurance_providers(
        specialist.id,
        [
          insurance_provider1.id,
          insurance_provider2.id
        ]
      )

      conn = get(conn, specialists_insurance_providers_path(conn, :index, specialist))

      assert %GetInsuranceProvidersV2{
               insurance_providers: [
                 %InsuranceProvidersEntryV2{name: "provider_name1"},
                 %InsuranceProvidersEntryV2{name: "provider_name2"}
               ],
               matching_provider: %Proto.SpecialistProfileV2.MatchingInsuranceProviderV2{
                 id: 0,
                 name: ""
               }
             } = proto_response(conn, 200, GetInsuranceProvidersV2)
    end

    test "returns list of insurance providers records when specialist doesn't have any providers",
         %{
           conn: conn,
           current_patient: current_patient,
           insurance_provider2: insurance_provider2,
           specialist: specialist
         } do
      _patient_insurance =
        Insurance.set_patient_insurance(
          %{provider_id: insurance_provider2.id, member_id: "member_id"},
          current_patient.id
        )

      conn = get(conn, specialists_insurance_providers_path(conn, :index, specialist))

      assert %GetInsuranceProvidersV2{
               insurance_providers: [],
               matching_provider: %MatchingInsuranceProviderV2{id: 0, name: ""}
             } = proto_response(conn, 200, GetInsuranceProvidersV2)
    end

    test "returns list of insurance providers records when patient nor specialist don't have any providers",
         %{
           conn: conn,
           specialist: specialist
         } do
      conn = get(conn, specialists_insurance_providers_path(conn, :index, specialist))

      assert %GetInsuranceProvidersV2{
               insurance_providers: [],
               matching_provider: %Proto.SpecialistProfileV2.MatchingInsuranceProviderV2{
                 id: 0,
                 name: ""
               }
             } = proto_response(conn, 200, GetInsuranceProvidersV2)
    end
  end
end
