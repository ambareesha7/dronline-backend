defmodule Web.Api.EMR.MedicationsController do
  use Web, :controller
  alias EMR.Medications
  alias EMR.Medications.MedicationOrder
  alias EMR.Medications.MedicationOrders
  alias EMR.PatientRecords.MedicationsBundle

  action_fallback Web.FallbackController

  @currency "AED"
  def history_for_record(conn, params) do
    record_id = String.to_integer(params["record_id"])
    {:ok, bundles} = EMR.fetch_medications_history_for_record(record_id)

    conn
    |> render("history.proto", %{
      bundles: bundles
    })
  end

  def show(conn, params) do
    # TODO: check if the record is for current patient
    bundle_id = String.to_integer(params["id"])

    with {:ok, bundle} <- EMR.fetch_medications_bundle(bundle_id),
         specialist_generic_data <- Web.SpecialistGenericData.get_by_id(bundle.specialist_id) do
      render(conn, "show.proto", %{bundle: bundle, specialist: specialist_generic_data})
    end
  end

  # Fetch medication order and create payment session with telr
  def fetch_medication_order(conn, params) do
    order_id = params["order_id"]

    with %MedicationOrder{} = meds_order <-
           MedicationOrders.get_medication_order(order_id),
         {:ok, %MedicationsBundle{} = bundle} <-
           EMR.fetch_by_bundle_id(meds_order.medications_bundle_id),
         {:ok, patient} <- get_patient(bundle.patient_id),
         {:ok, specialist} <- get_speciaist(bundle.specialist_id),
         bundle = parse_bundle(bundle),
         amount = parse_amount(bundle.medications) do
      # TODO: change response to protobuf
      case chech_meds_order_state(meds_order, conn.host, patient, amount) do
        {:ok, payment_url, ref} ->
          create_payment(bundle, meds_order, amount, ref)

          render(conn, "index.json", %{
            assigned_medications: bundle,
            specialist: specialist,
            patient: patient,
            total_amount: amount,
            payment_url: payment_url
          })

        _ ->
          render(conn, "index.json", %{
            assigned_medications: bundle,
            specialist: specialist,
            patient: patient,
            total_amount: amount,
            payment_url: nil
          })
      end
    end
  end

  def chech_meds_order_state(
        %MedicationOrder{payment_status: payment_status} = meds_order,
        host,
        patient,
        amount
      )
      when payment_status in [:none, :initiated] do
    case Medications.Payments.call(%{
           host: host,
           patient: patient,
           medication_order_id: meds_order.id,
           amount: amount,
           currency: @currency,
           description: "Medication order payment"
         }) do
      {:ok, payment_url, ref} ->
        {:ok, payment_url, ref}

      _ ->
        {:error, :error}
    end
  end

  # def fetch_medication_order_for_app(conn, %{"order_id" => order_id} = _params) do
  #   # order_id = params["order_id"]

  #   with %MedicationOrder{} = meds_order <- MedicationOrders.get_medication_order(order_id),
  #        {:ok, %MedicationsBundle{} = bundle} <-
  #          EMR.fetch_by_bundle_id(meds_order.medications_bundle_id),
  #        {:ok, patient} <- get_patient(bundle.patient_id),
  #        {:ok, specialist} <- get_speciaist(bundle.specialist_id),
  #        bundle <- parse_bundle(bundle),
  #        amount <- parse_amount(bundle.medications) do
  #     create_payment(bundle, meds_order, amount, meds_order.id)

  #     # TODO: change this to protobuf
  #     render(conn, "index.json", %{
  #       assigned_medications: bundle,
  #       specialist: specialist,
  #       patient: patient,
  #       total_amount: amount,
  #       payment_url: nil
  #     })
  #   end
  # end

  defp parse_bundle(bundle) do
    bundle
    |> Map.delete(:__meta__)
    |> Map.delete(:__struct__)
    |> Map.update(:medications, [], fn meds ->
      Enum.map(meds, fn m -> Map.from_struct(m) end)
    end)
  end

  def parse_amount(medications) do
    medications
    |> Enum.map(fn m -> parse_number(m.quantity) * m.price_aed end)
    |> Enum.sum()
  end

  defp parse_number(number) when is_integer(number) do
    number
  end

  defp parse_number(number) do
    case Integer.parse(number) do
      :error ->
        0

      {quantity, _} ->
        quantity
    end
  end

  defp get_speciaist(specialist_id) do
    specialist =
      specialist_id
      |> Web.SpecialistGenericData.get_by_id()
      |> Map.delete(:__struct__)
      |> Map.delete(:__meta__)
      |> Map.delete(:specialist)
      |> Map.update(:basic_info, %{}, fn m ->
        m
        |> Map.delete(:__struct__)
        |> Map.delete(:__meta__)
      end)
      |> Map.update(:medical_credential, %{}, fn m ->
        m
        |> Map.delete(:__struct__)
        |> Map.delete(:__meta__)
      end)

    {:ok, specialist}
  end

  defp get_patient(patient_id) do
    {:ok, patient} = PatientProfile.fetch_basic_info(patient_id)

    patient =
      patient
      |> Map.delete(:__struct__)
      |> Map.delete(:__meta__)

    {:ok, patient}
  end

  # TODO: write tests
  @decode Proto.Visits.LandingConfirmUSBoardSecondOpinionRequest
  def confirm_meds_payment(conn, %{"status" => payment_status} = _params) do
    meds_order_id = conn.assigns.protobuf.second_opinion_request_id

    with %MedicationOrder{} = meds_order <-
           MedicationOrders.get_medication_order(meds_order_id) do
      update_meds_send_paid_receipt(meds_order, payment_status)
      send_resp(conn, 200, "")
    end
  end

  # def confirm_meds_payment_from_app(
  #       conn,
  #       %{
  #         "status" => payment_status,
  #         "transaction_reference" => transaction_reference,
  #         "order_id" => order_id,
  #         "payment_method" => payment_method
  #       } = _params
  #     ) do
  #   with %MedicationOrder{} = meds_order <-
  #          MedicationOrders.get_medication_order(order_id) do
  #     update_meds_send_paid_receipt(meds_order, payment_status)

  #     Medications.Payments.update(meds_order.id, %{
  #       transaction_reference: transaction_reference,
  #       payment_method: payment_method
  #     })

  #     send_resp(conn, 200, "")
  #   end
  # end

  def update_meds_send_paid_receipt(meds_order, payment_status) do
    update_meds_order(payment_status, meds_order)
    Task.start(fn -> send_payment_receipt(meds_order) end)
  end

  # TODO: write tests
  def update_meds_order(payment_status, meds_order) do
    Task.start(fn ->
      case payment_status do
        "success" when is_binary(payment_status) ->
          MedicationOrders.update_medication_order(meds_order, %{
            delivery_status: :assigned,
            payment_status: :paid
          })

        "failure" when is_binary(payment_status) ->
          MedicationOrders.update_medication_order(meds_order, %{
            delivery_status: :cancelled,
            payment_status: :failed
          })
      end
    end)
  end

  # TODO: write tests
  def create_payment(bundle, meds_order, amount, ref) do
    # if we want to allow user order multiple time
    case Medications.Payments.fetch_by_medication_order_id(meds_order.id) do
      nil ->
        Task.start(fn ->
          Medications.Payments.create(%{
            medications_bundle_id: bundle.id,
            patient_id: bundle.patient_id,
            medication_order_id: meds_order.id,
            amount: amount,
            currency: @currency,
            payment_method: :TELR,
            transaction_reference: ref
          })

          MedicationOrders.update_medication_order(meds_order, %{
            delivery_status: :in_progres,
            payment_status: :initiated
          })
        end)

      _payment ->
        nil
    end
  end

  @decode Proto.EMR.SaveMedicationPayments
  def save_payment(conn, params) do
    meds_order_id = String.to_integer(params["id"])
    %MedicationOrder{} = meds_order = MedicationOrders.get_medication_order(meds_order_id)
    payment_params = conn.assigns.protobuf.payments_params

    create_payment_params =
      payment_params
      |> Map.from_struct()
      |> Map.merge(%{
        medications_bundle_id: meds_order.medications_bundle_id,
        medication_order_id: meds_order.id
      })

    with {:ok, %EMR.Medications.Payment{}} <-
           EMR.Medications.Payments.create(create_payment_params) do
      send_resp(conn, 200, "")
    end
  end

  def send_payment_receipt(%MedicationOrder{} = meds_order) do
    with {:ok, %MedicationsBundle{} = bundle} <-
           EMR.fetch_by_bundle_id(meds_order.medications_bundle_id),
         {:ok, patient} <- get_patient(bundle.patient_id),
         {:ok, specialist} <- get_speciaist(bundle.specialist_id),
         bundle = parse_bundle(bundle),
         medication_items = parse_medications(bundle.medications),
         %Medications.Payment{} = payment when not is_nil(payment) <-
           Medications.Payments.fetch_by_medication_order_id(meds_order.id) do
      %{
        amount: payment.price.amount,
        currency: Atom.to_string(payment.price.currency),
        date: meds_order.updated_at,
        patient_name: parse_name(patient.first_name, patient.last_name),
        patient_email: patient.email,
        order_id: meds_order.id,
        specialist_name:
          parse_name(specialist.basic_info.first_name, specialist.basic_info.last_name),
        medication_items: medication_items
      }
      |> Mailers.MedicationsMailer.send_pdf_receipt()
    end
  end

  defp parse_name(first_name, last_name) do
    first_name = if is_nil(first_name), do: "", else: first_name
    last_name = if is_nil(last_name), do: "", else: last_name
    "#{first_name} #{last_name}"
  end

  def parse_medications(medication_items) do
    medication_items
    |> Enum.with_index(1)
    |> Enum.map(fn {m, index} ->
      %{
        sr_no: index,
        name: m.name,
        quantity: m.quantity,
        frequency: m.direction,
        duration: m.refills
      }
    end)
  end
end

defmodule Web.Api.EMR.MedicationsView do
  use Web, :view

  def render("history.proto", %{
        bundles: bundles
      }) do
    %Proto.EMR.GetMedicationsHistoryResponse{
      bundles: Enum.map(bundles, &Web.View.EMR.render_medications_bundle/1)
    }
  end

  def render("show.proto", %{bundle: bundle, specialist: specialist}) do
    %{
      bundle: Web.View.EMR.render_medications_bundle(bundle),
      specialist: Web.View.Generics.render_specialist(specialist)
    }
    |> Proto.validate!(Proto.EMR.GetMedicationResponse)
    |> Proto.EMR.GetMedicationResponse.new()
  end

  def render("index.json", %{
        assigned_medications: assigned_medications,
        specialist: specialist,
        patient: patient,
        total_amount: amount,
        payment_url: payment_url
      }) do
    %{
      assigned_medications: assigned_medications,
      specialist: specialist,
      patient: patient,
      total_amount: amount,
      payment_url: payment_url
    }
  end

  def render("index.proto", %{
        bundles: bundles,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data
      }) do
    %Proto.EMR.GetMedicationsResponse{
      bundles: Enum.map(bundles, &Web.View.EMR.render_medications_bundle/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1),
      next_token: nil
    }
    |> Proto.validate!(Proto.EMR.GetMedicationsResponse)
    |> Proto.EMR.GetMedicationsResponse.new()
  end
end
