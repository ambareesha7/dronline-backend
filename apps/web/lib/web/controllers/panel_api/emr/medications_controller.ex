defmodule Web.PanelApi.EMR.MedicationsController do
  use Web, :controller

  import Mockery.Macro

  plug Web.Plugs.RequireOnboarding

  action_fallback Web.FallbackController

  alias EMR.Medications
  alias EMR.Medications.MedicationOrders

  @decode Proto.EMR.AssignMedicationsRequest
  def create(conn, params) do
    patient_id = String.to_integer(params["patient_id"])
    record_id = String.to_integer(params["record_id"])

    specialist_id = conn.assigns.current_specialist_id

    with {:ok, bundle} <-
           EMR.create_medications_bundle(
             patient_id,
             record_id,
             specialist_id,
             %{
               items:
                 conn.assigns.protobuf.items
                 |> Enum.map(&add_price(&1))
             }
           ) do
      _ =
        notify_user(
          record_id,
          patient_id,
          specialist_id,
          bundle
        )

      conn |> send_resp(200, "")
    end
  end

  # TODO: remove adding random price function once admin has the feature to add price
  def add_price(strct) do
    strct = Map.from_struct(strct)
    Map.update(strct, :price_aed, 0, fn _val -> get_medication_price(strct) end)
  end

  def get_medication_price(items_map) do
    case get_medication(items_map) do
      {:ok, result} ->
        result.price_aed

      _ ->
        0
    end
  end

  defp get_medication(items_map) do
    case Map.get(items_map, :medication_id) do
      nil ->
        Admin.fetch_medication_by_name(Map.get(items_map, :name))

      id when is_binary(id) ->
        Admin.fetch_medication_by_id(String.to_integer(id))

      id when is_integer(id) ->
        Admin.fetch_medication_by_id(id)

      _ ->
        {:error, :not_found}
    end
  end

  def notify_user(record_id, patient_id, specialist_id, bundle) do
    {:ok, specialist_info} = SpecialistProfile.fetch_basic_info(specialist_id)
    {:ok, patient_info} = PatientProfile.fetch_basic_info(patient_id)
    {:ok, patient_ph} = PatientProfile.fetch_by_id(patient_id)
    # use this function to join DB call and get phone_number, email
    # {:ok, patient_ph} = PatientProfile.get_patient_details(patient_id)

    NotificationsWrite.notify_patient_about_record_change(
      record_id,
      patient_id,
      specialist_id,
      medications_bundle_id: bundle.id
    )

    case order_medications(patient_id, bundle.id) do
      {:ok, order} ->
        # build dynamic link
        dynamic_link = " https://stg.dronline.me/medication-order?id=#{order.id}"
        specialist_name = "#{specialist_info.first_name} #{specialist_info.last_name}"
        send_patient_email(patient_info.email, specialist_name, dynamic_link)
        send_sms(patient_ph.phone_number, specialist_name, dynamic_link)

      _ ->
        :error
    end
  end

  @spec order_medications(pos_integer(), pos_integer()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def order_medications(patient_id, bundle_id) do
    %{
      medications_bundle_id: bundle_id,
      patient_id: patient_id,
      delivery_address: get_address(patient_id)
    }
    |> MedicationOrders.create_medication_order()
  end

  @spec get_address(pos_integer()) :: String.t()
  def get_address(patient_id) do
    case PatientProfile.get_address(patient_id) do
      %PatientProfile.Address{} = result ->
        {:ok, address} =
          result
          |> Map.delete(:__struct__)
          |> Map.delete(:__meta__)
          |> Jason.encode()

        address

      _ ->
        "none"
    end
  end

  def send_patient_email(email, specialist_name, dynamic_link) do
    %{
      type: "PATIENT_ASSIGN_MEDICATIONS",
      dynamic_link: dynamic_link,
      patient_email: email,
      specialist_data: specialist_name
    }
    |> Mailers.MailerJobs.new()
    |> Oban.insert()
  end

  defp send_sms("", _, _), do: :ok
  defp send_sms(nil, _, _), do: :ok

  defp send_sms(phone_number, specialist_name, dynamic_link) do
    body =
      "Dr. #{specialist_name} " <>
        "has assigned you medications please click on the link #{dynamic_link} to order the medicine"

    resp =
      mockable(Twilio.SMSClient, by: Twilio.SMSClientMock).send(
        phone_number,
        body
      )

    case resp do
      :ok ->
        :ok

      {:error, {:ok, %Tesla.Env{body: %{"message" => message}}}} ->
        {:error, message}
    end
  end

  def index(conn, params) do
    specialist_id = conn.assigns.current_specialist_id
    params = Medications.decode_next_token(params)

    with {:ok, medications_bundles, next_token} <-
           Medications.get_for_specialist(specialist_id, params) do
      specialists_generic_data =
        medications_bundles
        |> Enum.map(& &1.specialist_id)
        |> Enum.uniq()
        |> Web.SpecialistGenericData.get_by_ids()

      patients_generic_data =
        medications_bundles
        |> Enum.map(& &1.patient_id)
        |> Enum.uniq()
        |> Web.PatientGenericData.get_by_ids()

      render(conn, "index.proto", %{
        bundles: medications_bundles,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      })
    end
  end

  def history_for_record(conn, params) do
    record_id = String.to_integer(params["record_id"])
    {:ok, bundles} = EMR.fetch_medications_history_for_record(record_id)

    conn
    |> render("history.proto", %{
      bundles: bundles
    })
  end
end

defmodule Web.PanelApi.EMR.MedicationsView do
  use Web, :view

  alias EMR.Medications

  def render("index.proto", %{
        bundles: bundles,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      }) do
    %Proto.EMR.GetMedicationsResponse{
      bundles: Enum.map(bundles, &Web.View.EMR.render_medications_bundle/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1),
      next_token: Medications.encode_next_token(next_token)
    }
  end

  def render("history.proto", %{
        bundles: bundles
      }) do
    %Proto.EMR.GetMedicationsHistoryResponse{
      bundles: Enum.map(bundles, &Web.View.EMR.render_medications_bundle/1)
    }
  end
end
