defmodule Postgres.Repo.Migrations.CreateTableAndTriggersForDoctorsFiltering do
  use Ecto.Migration

  def change do
    create table(:doctor_filter_datas, primary_key: false) do
      add :specialist_id, references(:specialists, on_delete: :delete_all), primary_key: true
      add :filter_data, :tsvector
    end

    # create helper function
    execute """
    CREATE FUNCTION prepare_doctor_filter_data(bigint) RETURNS tsvector AS
    $func$
    DECLARE filter_data tsvector;
    BEGIN
      SELECT to_tsvector('simple', specialist_basic_infos.first_name) ||
             to_tsvector('simple', specialist_basic_infos.last_name) ||
             to_tsvector('simple', specialist_basic_infos.title) ||
             to_tsvector('simple', specialists.package_type) ||
             to_tsvector('simple', specialist_locations.country)
      INTO filter_data
      FROM specialists
      INNER JOIN specialist_basic_infos ON specialist_basic_infos.specialist_id = specialists.id
      INNER JOIN specialist_locations ON specialist_locations.specialist_id = specialists.id
      WHERE specialists.id = $1;

      RETURN filter_data;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger function
    execute """
    CREATE FUNCTION upsert_doctor_filter_data() RETURNS trigger AS
    $func$
    DECLARE
      specialist_id_to_update bigint;
    BEGIN
      IF TG_ARGV[0] = 'id' THEN
        specialist_id_to_update := NEW.id;
      ELSE
        specialist_id_to_update := NEW.specialist_id;
      END IF;

      INSERT INTO doctor_filter_datas(specialist_id, filter_data)
      VALUES
      (
        specialist_id_to_update,
        prepare_doctor_filter_data(specialist_id_to_update)
      )
      ON CONFLICT (specialist_id)
      DO
        UPDATE
          SET filter_data = EXCLUDED.filter_data;

      RETURN NEW;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger on specialist_basic_infos
    execute """
    CREATE TRIGGER upsert_doctor_filter_data_trigger
    AFTER INSERT OR UPDATE ON specialist_basic_infos FOR EACH ROW
    EXECUTE PROCEDURE upsert_doctor_filter_data('specialist_id');
    """

    # create trigger on specialist_locations
    execute """
    CREATE TRIGGER upsert_doctor_filter_data_trigger
    AFTER INSERT OR UPDATE ON specialist_locations FOR EACH ROW
    EXECUTE PROCEDURE upsert_doctor_filter_data('specialist_id');
    """

    # create trigger on specialists
    execute """
    CREATE TRIGGER upsert_doctor_filter_data_trigger
    AFTER INSERT OR UPDATE ON specialists FOR EACH ROW
    EXECUTE PROCEDURE upsert_doctor_filter_data('id');
    """

    # populate table
    execute """
    INSERT INTO doctor_filter_datas
    SELECT specialist_basic_infos.specialist_id,
          to_tsvector('simple', specialist_basic_infos.first_name) ||
          to_tsvector('simple', specialist_basic_infos.last_name) ||
          to_tsvector('simple', specialist_basic_infos.title) ||
          to_tsvector('simple', specialists.package_type) ||
          to_tsvector('simple', specialist_locations.country)
    FROM specialists
    INNER JOIN specialist_basic_infos ON specialist_basic_infos.specialist_id = specialists.id
    INNER JOIN specialist_locations ON specialist_locations.specialist_id = specialists.id;
    """
  end
end
