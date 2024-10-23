defmodule Web.AdminApi.MedicationsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def uploads(
        conn,
        %{"medications" => %Plug.Upload{path: path, content_type: "text/csv"}}
      ) do
    # Admin.Medications.seed_from_csv(path)
    Admin.Medications.seed_old_table(path)
    send_resp(conn, 200, "ok")
  end

  def uploads(conn, _) do
    send_resp(conn, 400, "Bad request")
  end

  def get_all_meds(conn, _params) do
    medications = Admin.Medications.list_old_medications()
    render(conn, "index_old.json", %{medications: medications})
    # medications = Admin.Medications.list_medications()
    # render(conn, "index.json", %{medications: medications})
  end

  def delete_all_meds(conn, _params) do
    # Admin.Medications.delete_all_medication()
    Admin.Medications.delete_all_medication_old_table()
    send_resp(conn, 200, "ok")
  end
end

defmodule Web.AdminApi.MedicationsView do
  use Web, :view
  alias Admin.Medications.NewMedication

  def render("index.json", %{medications: medications}) do
    %{medications: for(new_medication <- medications, do: data(new_medication))}
  end

  def render("index_old.json", %{medications: medications}) do
    %{medications: for(new_medication <- medications, do: data_old(new_medication))}
  end

  defp data(%NewMedication{} = new_medication) do
    %{
      id: new_medication.id,
      name: new_medication.name,
      price: new_medication.price,
      currency: new_medication.currency,
      inserted_at: new_medication.inserted_at,
      updated_at: new_medication.updated_at
    }
  end

  defp data_old(new_medication) do
    %{
      id: new_medication.id,
      name: new_medication.name,
      price_aed: new_medication.price_aed
    }
  end
end
