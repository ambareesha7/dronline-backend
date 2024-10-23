defmodule UrgentCare.InitializeTest do
  use Postgres.DataCase, async: true

  alias UrgentCare.Initialize

  describe "call/1" do
    test "returns the payment URL when all steps succeed" do
      params = %{
        patient: %{
          patient_id: 1,
          patient_email: "fail@example.com",
          first_name: "Andrju",
          last_name: "Testowy"
        },
        host: "testhost.com"
      }

      assert {:ok, result} = Initialize.call(params)

      assert %{
               payment_url: actual_url,
               urgent_care_request_id: urgent_care_request_id
             } = result

      expected_url = "https://secure.telr.com/gateway/process.html?o=#{urgent_care_request_id}"

      assert actual_url == expected_url
    end

    test "returns error when patient id is invalid" do
      params = %{
        patient: %{
          patient_id: "invalid",
          patient_email: "fail@example.com",
          first_name: "Andrju",
          last_name: "Testowy"
        },
        host: "testhost.com"
      }

      {:error,
       %Ecto.Changeset{
         errors: [patient_id: {"is invalid", [type: :integer, validation: :cast]}],
         valid?: false
       }} =
        Initialize.call(params)
    end
  end
end
