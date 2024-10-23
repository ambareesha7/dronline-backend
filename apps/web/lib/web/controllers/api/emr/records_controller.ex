defmodule Web.Api.EMR.RecordsController do
  use Web, :controller

  import Mockery.Macro

  action_fallback Web.FallbackController

  def index(conn, params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, records, next_token} = EMR.fetch_patient_records(patient_id, params)

    {:ok, basic_infos} =
      records
      |> Enum.map(& &1.created_by_specialist_id)
      |> Enum.uniq()
      |> Enum.reject(&is_nil/1)
      |> SpecialistProfile.fetch_basic_infos()

    specialists_generic_data =
      records
      |> Enum.flat_map(&EMR.get_record_main_specialist_ids/1)
      |> Enum.uniq()
      |> Web.SpecialistGenericData.get_by_ids()

    conn
    |> render("index.proto", %{
      records: records,
      basic_infos: basic_infos,
      next_token: next_token |> Web.ControllerHelper.next_token_to_string(),
      specialists_generic_data: specialists_generic_data
    })
  end

  def show(conn, params) do
    patient_id = conn.assigns.current_patient_id
    %{"id" => record_id} = params

    with {:ok, record} <- EMR.fetch_patient_record(record_id, patient_id) do
      {:ok, basic_infos} = SpecialistProfile.fetch_basic_infos([record.created_by_specialist_id])

      specialists_generic_data =
        record |> EMR.get_record_main_specialist_ids() |> Web.SpecialistGenericData.get_by_ids()

      conn
      |> render("show.proto", %{
        record: record,
        basic_infos: basic_infos,
        specialists_generic_data: specialists_generic_data
      })
    end
  end

  def pdf(conn, params) do
    patient_id = conn.assigns.current_patient_id
    %{"id" => record_id} = params
    token = conn |> get_req_header("x-auth-token") |> List.first()

    with {:ok, _record} <- EMR.fetch_patient_record(record_id, patient_id) do
      {:ok, pdf_body} = mockable(EMR).generate_record_pdf_for_patient(record_id, token)

      conn
      |> put_resp_content_type("application/pdf")
      |> send_resp(200, pdf_body)
    end
  end
end

defmodule Web.Api.EMR.RecordsView do
  use Web, :view

  defp to_map(basic_info), do: Enum.into(basic_info, %{}, &{&1.specialist_id, &1})

  def render("create.proto", %{record: record, basic_infos: basic_infos}) do
    basic_infos_map = to_map(basic_infos)

    %Proto.EMR.CreateMedicalRecordResponse{
      patient_record: Web.View.EMR.render_record(record, basic_infos_map)
    }
  end

  def render("index.proto", %{
        records: records,
        basic_infos: basic_infos,
        next_token: next_token,
        specialists_generic_data: specialists_generic_data
      }) do
    basic_infos_map = to_map(basic_infos)

    %Proto.EMR.GetPatientRecordsResponse{
      patient_records: Enum.map(records, &Web.View.EMR.render_record(&1, basic_infos_map)),
      next_token: next_token,
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("show.proto", %{
        record: record,
        basic_infos: basic_infos,
        specialists_generic_data: specialists_generic_data
      }) do
    basic_infos_map = to_map(basic_infos)

    %Proto.EMR.GetPatientRecordResponse{
      patient_record: Web.View.EMR.render_record(record, basic_infos_map),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end
end
