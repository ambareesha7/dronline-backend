defmodule Postgres.Repo.Migrations.UsePatientInsteadOfUser do
  use Ecto.Migration

  def change do
    # PATIENTS TABLE
    rename table(:users), to: table(:patients)
    rename_index("users_pkey", "patients_pkey")
    rename_index("users_auth_token_index", "patients_auth_token_index")
    rename_index("users_firebase_id_index", "patients_firebase_id_index")
    rename_index("users_phone_number_index", "patients_phone_number_index")
    rename_sequence("users_id_seq", "patients_id_seq")

    # PATIENT ADDRESSES TABLE
    rename table(:user_addresses), to: table(:patient_addresses)
    rename table(:patient_addresses), :user_id, to: :patient_id
    rename_index("user_addresses_pkey", "patient_addresses_pkey")
    rename_index("user_addresses_user_id_index", "patient_addresses_patient_id_index")

    rename_constraint(
      "patient_addresses",
      "user_addresses_user_id_fkey",
      "patient_addresses_patient_id_fkey"
    )

    rename_sequence("user_addresses_id_seq", "patient_addresses_id_seq")

    # PATIENT BASIC INFOS TABLE
    rename table(:user_basic_infos), to: table(:patient_basic_infos)
    rename table(:patient_basic_infos), :user_id, to: :patient_id
    rename_index("user_basic_infos_pkey", "patient_basic_infos_pkey")
    rename_index("user_basic_infos_user_id_index", "patient_basic_infos_patient_id_index")

    rename_constraint(
      "patient_basic_infos",
      "user_basic_infos_user_id_fkey",
      "patient_basic_infos_patient_id_fkey"
    )

    rename_sequence("user_basic_infos_id_seq", "patient_basic_infos_id_seq")

    # PATIENT BLOOD PRESSURES TABLE
    rename table(:user_blood_pressures), to: table(:patient_blood_pressures)
    rename table(:patient_blood_pressures), :user_id, to: :patient_id
    rename_index("user_blood_pressures_pkey", "patient_blood_pressures_pkey")
    rename_index("user_blood_pressures_user_id_index", "patient_blood_pressures_patient_id_index")

    rename_constraint(
      "patient_blood_pressures",
      "user_blood_pressures_user_id_fkey",
      "patient_blood_pressures_patient_id_fkey"
    )

    rename_sequence("user_blood_pressures_id_seq", "patient_blood_pressures_id_seq")

    # PATIENT BMIS TABLE
    rename table(:user_bmis), to: table(:patient_bmis)
    rename table(:patient_bmis), :user_id, to: :patient_id
    rename_index("user_bmis_pkey", "patient_bmis_pkey")
    rename_index("user_bmis_user_id_index", "patient_bmis_patient_id_index")
    rename_constraint("patient_bmis", "user_bmis_user_id_fkey", "patient_bmis_patient_id_fkey")
    rename_sequence("user_bmis_id_seq", "patient_bmis_id_seq")

    # PATIENT HISTORY FORMS TABLE
    rename table(:user_history_forms), to: table(:patient_history_forms)
    rename table(:patient_history_forms), :user_id, to: :patient_id
    rename_index("user_history_forms_pkey", "patient_history_forms_pkey")
    rename_index("user_history_forms_user_id_index", "patient_history_forms_patient_id_index")

    rename_constraint(
      "patient_history_forms",
      "user_history_forms_user_id_fkey",
      "patient_history_forms_patient_id_fkey"
    )

    rename_sequence("user_history_forms_id_seq", "patient_history_forms_id_seq")

    # PATIENT QUEUE PROJECTION TABLE
    rename table(:users_queue_projection), to: table(:patients_queue_projection)
    rename_index("users_queue_projection_pkey", "patients_queue_projection_pkey")
    rename_sequence("users_queue_projection_id_seq", "patients_queue_projection_id_seq")

    # CALLS TABLE
    rename table(:calls), :user_id, to: :patient_id
    rename_index("calls_user_id_index", "calls_patient_id_index")
    rename_constraint("calls", "calls_user_id_fkey", "calls_patient_id_fkey")

    # DISPATCH REQUESTS TABLE
    rename table(:dispatch_requests), :user_id, to: :patient_id
    rename_index("dispatch_requests_user_id_index", "dispatch_requests_patient_id_index")

    rename_constraint(
      "dispatch_requests",
      "dispatch_requests_user_id_fkey",
      "dispatch_requests_patient_id_fkey"
    )

    # DISPATCHES TABLE
    rename table(:dispatches), :user_id, to: :patient_id
    rename_index("dispatches_user_id_index", "dispatches_patient_id_index")
    rename_constraint("dispatches", "dispatches_user_id_fkey", "dispatches_patient_id_fkey")

    # DOCTOR INVITATIONS TABLE
    rename table(:doctor_invitations), :user_id, to: :patient_id
    rename_index("doctor_invitations_user_id_index", "doctor_invitations_patient_id_index")

    rename_constraint(
      "doctor_invitations",
      "doctor_invitations_user_id_fkey",
      "doctor_invitations_patient_id_fkey"
    )

    # FAVOURITE PROVIDERS TABLE
    rename table(:favourite_providers), :user_id, to: :patient_id

    rename_index(
      "favourite_providers_user_id_index",
      "favourite_providers_patient_id_index"
    )

    rename_index(
      "favourite_providers_user_id_specialist_id_index",
      "favourite_providers_patient_id_specialist_id_index"
    )

    rename_constraint(
      "favourite_providers",
      "favourite_providers_user_id_fkey",
      "favourite_providers_patient_id_fkey"
    )

    # SPECIALIST PATIENT CONNECTIONS TABLE
    rename table(:specialist_patient_connections), :user_id, to: :patient_id

    rename_index(
      "specialist_patient_connections_user_id_specialist_id_index",
      "specialist_patient_connections_patient_id_specialist_id_index"
    )

    rename_constraint(
      "specialist_patient_connections",
      "specialist_patient_connections_user_id_fkey",
      "specialist_patient_connections_patient_id_fkey"
    )

    # TIMELINES TABLE
    rename table(:timelines), :user_id, to: :patient_id
    rename_index("timelines_active_user_id_index", "timelines_active_patient_id_index")
    rename_constraint("timelines", "timelines_user_id_fkey", "timelines_patient_id_fkey")

    # VISITS TABLE
    rename table(:visits), :user_id, to: :patient_id
    rename_index("visits_user_id_index", "visits_patient_id_index")
    rename_constraint("visits", "visits_user_id_fkey", "visits_patient_id_fkey")

    # VITALS TABLE
    rename table(:vitals), :user_id, to: :patient_id
    rename_index("vitals_user_id_index", "vitals_patient_id_index")
    rename_constraint("vitals", "vitals_user_id_fkey", "vitals_patient_id_fkey")

    execute "DROP TRIGGER upsert_user_filter_data_trigger ON patient_basic_infos;"
    execute "DROP FUNCTION upsert_user_filter_data();"
    execute "DROP FUNCTION prepare_user_filter_data(bigint);"

    drop table(:user_filter_datas)

    # create new ones
    create table(:patient_filter_datas, primary_key: false) do
      add :patient_id, references(:patients, on_delete: :delete_all), primary_key: true
      add :filter_data, :tsvector
    end

    # create helper function
    execute """
    CREATE FUNCTION prepare_patient_filter_data(bigint) RETURNS tsvector AS
    $func$
    DECLARE filter_data tsvector;
    BEGIN
      SELECT to_tsvector('simple', patient_basic_infos.first_name) ||
             to_tsvector('simple', patient_basic_infos.last_name) ||
             to_tsvector('simple', patients.phone_number)
      INTO filter_data
      FROM patients
      INNER JOIN patient_basic_infos ON patient_basic_infos.patient_id = patients.id
      WHERE patients.id = $1;

      RETURN filter_data;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger function
    execute """
    CREATE FUNCTION upsert_patient_filter_data() RETURNS trigger AS
    $func$
    BEGIN
      INSERT INTO patient_filter_datas(patient_id, filter_data)
      VALUES
      (
        NEW.patient_id,
        prepare_patient_filter_data(NEW.patient_id)
      )
      ON CONFLICT (patient_id)
      DO
        UPDATE
          SET filter_data = EXCLUDED.filter_data;

      RETURN NEW;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger on patient_basic_infos
    execute """
    CREATE TRIGGER upsert_patient_filter_data_trigger
    AFTER INSERT OR UPDATE ON patient_basic_infos FOR EACH ROW
    EXECUTE PROCEDURE upsert_patient_filter_data();
    """

    # populate table
    execute """
    INSERT INTO patient_filter_datas
    SELECT patient_basic_infos.patient_id,
           to_tsvector('simple', patient_basic_infos.first_name) ||
           to_tsvector('simple', patient_basic_infos.last_name) ||
           to_tsvector('simple', patients.phone_number)
    FROM patients
    INNER JOIN patient_basic_infos ON patient_basic_infos.patient_id = patients.id;
    """
  end

  defp rename_index(from, to) do
    execute "ALTER INDEX #{from} RENAME TO #{to}"
  end

  def rename_constraint(table, from, to) do
    execute "ALTER TABLE #{table} RENAME CONSTRAINT #{from} TO #{to}"
  end

  defp rename_sequence(from, to) do
    execute "ALTER SEQUENCE #{from} RENAME TO #{to}"
  end
end
