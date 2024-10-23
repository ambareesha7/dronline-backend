defmodule UrgentCare.PatientsQueue.Add do
  alias UrgentCare.AreaDispatch
  alias UrgentCare.PatientsQueue.Schema
  alias UrgentCare.Request

  alias Postgres.Repo

  def call(%{patient_id: nil}) do
    {:error, "patient_id can't be blank"}
  end

  def call(%{device_id: _device_id, patient_id: patient_id, record_id: nil} = args) do
    {:ok, record} = EMR.fetch_or_create_automatic_record(patient_id)

    args |> Map.put(:record_id, record.id) |> call()
  end

  def call(%{device_id: _device_id, patient_id: patient_id, record_id: _record_id} = args) do
    # For now we use only the default team clinic
    team_ids = [AreaDispatch.default_team_id()]

    patient_id
    |> Schema.fetch_by_patient_id()
    |> maybe_add_to_queue(args, team_ids)
    |> case do
      {:ok, queue_entry} ->
        broadcast_update()

        queue_entry

      {:error, :already_joined_on_another_device} ->
        {:error, :already_joined_on_another_device}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_add_to_queue(
         nil,
         %{
           device_id: device_id,
           patient_id: patient_id,
           record_id: record_id,
           payment_params: payment_params
         },
         handling_team_ids
       ) do
    params = %{
      device_id: device_id || "LANDING_PAGE",
      patient_id: patient_id,
      handling_team_ids: handling_team_ids,
      record_id: record_id,
      payment_params: payment_params
    }

    Ecto.Multi.new()
    |> Ecto.Multi.run(:params, fn _, _ -> {:ok, params} end)
    |> Ecto.Multi.run(:validate_handling_team_ids, &validate_handling_team_ids/2)
    |> Ecto.Multi.merge(&upsert_urgent_care_request/1)
    |> Ecto.Multi.run(:insert_to_queue, &insert_to_queue/2)
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, %{insert_to_queue: insert_to_queue}} ->
        {:ok, insert_to_queue}

      {:error, _failed_operation, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  defp maybe_add_to_queue(_, _, _) do
    {:error, :already_joined_on_another_device}
  end

  defp validate_handling_team_ids(_repo, %{params: params}) do
    if Enum.empty?(params.handling_team_ids) do
      {:error, :no_handling_teams_available}
    else
      {:ok, true}
    end
  end

  defp insert_to_queue(_repo, %{params: params}) do
    %Schema{}
    |> Schema.changeset(params)
    |> Repo.insert()
  end

  defp upsert_urgent_care_request(%{params: params}) do
    params.patient_id
    |> UrgentCare.fetch_pending_urgent_care_request_for_patient()
    |> case do
      {:ok, urgent_care_request} ->
        Ecto.Multi.new()
        |> Ecto.Multi.run(:add_payment_to_request, fn _, _ ->
          add_payment_to_request(urgent_care_request, params.payment_params)
        end)
        |> Ecto.Multi.run(:add_patient_record_id_to_urgent_care, fn _, _ ->
          Request.add_patient_record(urgent_care_request, params.record_id)
        end)

      {:error, :not_found} ->
        Ecto.Multi.new()
        |> Ecto.Multi.run(:params_falltrough, fn _, _ -> {:ok, params} end)
        |> Ecto.Multi.run(:insert_urgent_care_request, &insert_urgent_care_request/2)
    end
  end

  defp insert_urgent_care_request(_repo, %{params_falltrough: params}) do
    {price_amount, _} = Integer.parse(params.payment_params.amount)

    %{
      patient_id: params.patient_id,
      patient_record_id: params.record_id,
      payment: %{
        transaction_reference: params.payment_params.transaction_reference,
        payment_method:
          params.payment_params.payment_method
          |> Atom.to_string()
          |> String.downcase()
          |> String.to_existing_atom(),
        price: %Money{
          amount: price_amount,
          currency: params.payment_params.currency
        }
      }
    }
    |> Request.create()
    |> case do
      {:error, changeset} -> {:error, changeset}
      {:ok, result} -> {:ok, result}
    end
  end

  defp add_payment_to_request(urgent_care_request, payment_params) do
    {price_amount, _} = Integer.parse(payment_params.amount)

    payment_attrs = %{
      transaction_reference: payment_params.transaction_reference,
      payment_method:
        payment_params.payment_method
        |> Atom.to_string()
        |> String.downcase()
        |> String.to_existing_atom(),
      price: %Money{
        amount: price_amount,
        currency: payment_params.currency
      }
    }

    Request.add_payment(urgent_care_request.id, payment_attrs)
  end

  def broadcast_update do
    Calls.ChannelBroadcast.broadcast(:patients_queue_update)
  end
end
