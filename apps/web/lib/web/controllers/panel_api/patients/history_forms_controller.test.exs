defmodule Web.PanelApi.Patients.HistoryFormsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Errors
  alias Proto.PatientProfile.GetHistoryResponse
  alias Proto.PatientProfile.UpdateAllHistoryRequest
  alias Proto.PatientProfile.UpdateAllHistoryResponse
  alias Proto.PatientProfile.UpdateHistoryRequest
  alias Proto.PatientProfile.UpdateHistoryResponse

  alias Proto.Forms.Form

  describe "GET show" do
    setup [:authenticate_gp]

    test "success when history forms don't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      conn = get(conn, panel_patients_history_forms_path(conn, :show, patient))

      assert %GetHistoryResponse{allergy: %Form{fields: fields}} =
               proto_response(conn, 200, GetHistoryResponse)

      assert Enum.count(fields) > 0
    end

    test "success when history forms exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      _history_forms =
        PatientProfile.Factory.insert(:history_forms,
          patient_id: patient.id,
          allergy:
            %{
              fields: []
            }
            |> Proto.Forms.Form.new()
            |> Proto.Forms.Form.encode()
        )

      conn = get(conn, panel_patients_history_forms_path(conn, :show, patient))

      assert %GetHistoryResponse{allergy: %Form{fields: []}} =
               proto_response(conn, 200, GetHistoryResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success when history forms don't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      proto =
        %{
          updated: {:allergy, Proto.Forms.Form.new()}
        }
        |> UpdateHistoryRequest.new()
        |> UpdateHistoryRequest.encode()

      conn = put(conn, panel_patients_history_forms_path(conn, :update, patient), proto)

      assert %UpdateHistoryResponse{allergy: %Form{fields: []}} =
               proto_response(conn, 200, UpdateHistoryResponse)
    end

    test "success when history forms do exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      _history_forms =
        PatientProfile.Factory.insert(:history_forms,
          patient_id: patient.id,
          allergy:
            %{
              fields: [Proto.Forms.FormField.new()]
            }
            |> Proto.Forms.Form.new()
            |> Proto.Forms.Form.encode()
        )

      proto =
        %{
          updated: {:allergy, Proto.Forms.Form.new()}
        }
        |> UpdateHistoryRequest.new()
        |> UpdateHistoryRequest.encode()

      conn = put(conn, panel_patients_history_forms_path(conn, :update, patient), proto)

      assert %UpdateHistoryResponse{allergy: %Form{fields: []}} =
               proto_response(conn, 200, UpdateHistoryResponse)
    end

    test "fail when history form isn't valid", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      form_proto =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              uuid: "uuid",
              label: "label",
              value: {:integer, Proto.Forms.IntegerField.new()}
            )
          ]
        )

      proto =
        %{
          updated: {:social, form_proto}
        }
        |> UpdateHistoryRequest.new()
        |> UpdateHistoryRequest.encode()

      conn = put(conn, panel_patients_history_forms_path(conn, :update, patient), proto)

      assert %Errors.ErrorResponse{
               form_errors: %Errors.FormErrors{
                 field_errors: [
                   %Errors.FormErrors.FieldError{
                     field: "uuid",
                     message: "This field is required"
                   }
                 ]
               }
             } = proto_response(conn, 422, Errors.ErrorResponse)
    end
  end

  describe "PUT update all" do
    setup [:proto_content, :authenticate_gp]

    test "success when history forms don't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      proto =
        %{
          allergy: Proto.Forms.Form.new()
        }
        |> UpdateAllHistoryRequest.new()
        |> UpdateAllHistoryRequest.encode()

      conn = put(conn, panel_patients_history_forms_path(conn, :update_all, patient), proto)

      assert %UpdateAllHistoryResponse{allergy: %Form{fields: []}} =
               proto_response(conn, 200, UpdateAllHistoryResponse)
    end

    test "success when history forms do exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      _history_forms =
        PatientProfile.Factory.insert(:history_forms,
          patient_id: patient.id,
          allergy:
            %{
              fields: [Proto.Forms.FormField.new()]
            }
            |> Proto.Forms.Form.new()
            |> Proto.Forms.Form.encode()
        )

      proto =
        %{
          allergy: Proto.Forms.Form.new()
        }
        |> UpdateAllHistoryRequest.new()
        |> UpdateAllHistoryRequest.encode()

      conn = put(conn, panel_patients_history_forms_path(conn, :update_all, patient), proto)

      assert %UpdateAllHistoryResponse{allergy: %Form{fields: []}} =
               proto_response(conn, 200, UpdateAllHistoryResponse)
    end

    test "fail when history form isn't valid", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      form_proto =
        Proto.Forms.Form.new(
          completed: false,
          fields: [
            Proto.Forms.FormField.new(
              uuid: "uuid",
              label: "label",
              value: {:integer, Proto.Forms.IntegerField.new()}
            )
          ]
        )

      proto =
        %{
          social: form_proto
        }
        |> UpdateAllHistoryRequest.new()
        |> UpdateAllHistoryRequest.encode()

      conn = put(conn, panel_patients_history_forms_path(conn, :update_all, patient), proto)

      assert %Errors.ErrorResponse{
               form_errors: %Errors.FormErrors{
                 field_errors: [
                   %Errors.FormErrors.FieldError{
                     field: "uuid",
                     message: "This field is required"
                   }
                 ]
               }
             } = proto_response(conn, 422, Errors.ErrorResponse)
    end
  end
end
