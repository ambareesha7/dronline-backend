defmodule Postgres.Repo.Migrations.CreateTableAndTriggersForSpecialistsSearch do
  use Ecto.Migration

  def change do
    create table(:specialist_search_datas, primary_key: false) do
      add :specialist_id, references(:specialists, on_delete: :delete_all), primary_key: true
      add :filter_data, :tsvector
    end

    # create helper function
    execute """
    CREATE FUNCTION specialist_search_data(bigint) RETURNS tsvector AS
    $func$
    DECLARE filter_data tsvector;
    BEGIN
      SELECT to_tsvector('simple', specialist_basic_infos.first_name) ||
             to_tsvector('simple', specialist_basic_infos.last_name) ||
             to_tsvector('simple', specialist_locations.country) ||
             to_tsvector('simple', specialist_locations.city) ||
             to_tsvector('simple', medical_categories.name)
      INTO filter_data
      FROM specialists
      INNER JOIN specialist_basic_infos ON specialist_basic_infos.specialist_id = specialists.id
      INNER JOIN specialist_locations ON specialist_locations.specialist_id = specialists.id
      INNER JOIN specialists_medical_categories ON specialists_medical_categories.specialist_id = specialists.id
      INNER JOIN medical_categories ON specialists_medical_categories.medical_category_id = medical_categories.id
      WHERE specialists.id = $1;

      RETURN filter_data;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger function
    execute """
    CREATE FUNCTION upsert_specialist_search_data() RETURNS trigger AS
    $func$
    BEGIN
      INSERT INTO specialist_search_datas(specialist_id, filter_data)
      VALUES
      (
        NEW.specialist_id,
        specialist_search_data(NEW.specialist_id)
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
    CREATE TRIGGER upsert_specialist_search_data_trigger
    AFTER INSERT OR UPDATE ON specialist_basic_infos FOR EACH ROW
    EXECUTE PROCEDURE upsert_specialist_search_data();
    """

    # create trigger on specialist_locations
    execute """
    CREATE TRIGGER upsert_specialist_search_data_trigger
    AFTER INSERT OR UPDATE ON specialist_locations FOR EACH ROW
    EXECUTE PROCEDURE upsert_specialist_search_data();
    """

    # create trigger on specialists_medical_categories
    execute """
    CREATE TRIGGER upsert_specialist_search_data_trigger
    AFTER INSERT OR UPDATE ON specialists_medical_categories FOR EACH ROW
    EXECUTE PROCEDURE upsert_specialist_search_data();
    """

    # populate table
    execute """
    INSERT INTO specialist_search_datas
    SELECT specialist_basic_infos.specialist_id,
          to_tsvector('simple', specialist_basic_infos.first_name) ||
          to_tsvector('simple', specialist_basic_infos.last_name) ||
          to_tsvector('simple', specialist_locations.country) ||
          to_tsvector('simple', specialist_locations.city) ||
          to_tsvector('simple', medical_categories.name)
    FROM specialists
    INNER JOIN specialist_basic_infos ON specialist_basic_infos.specialist_id = specialists.id
    INNER JOIN specialist_locations ON specialist_locations.specialist_id = specialists.id
    INNER JOIN specialists_medical_categories ON specialists_medical_categories.specialist_id = specialists.id
    INNER JOIN medical_categories ON specialists_medical_categories.medical_category_id = medical_categories.id
    ON CONFLICT ON CONSTRAINT specialist_search_datas_pkey DO NOTHING;
    """
  end
end
