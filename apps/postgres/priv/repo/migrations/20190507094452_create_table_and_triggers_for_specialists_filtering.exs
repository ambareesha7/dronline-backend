defmodule Postgres.Repo.Migrations.CreateTableAndTriggersForSpecialistsFiltering do
  use Ecto.Migration

  def change do
    create table(:specialist_filter_datas, primary_key: false) do
      add :specialist_id, references(:specialists, on_delete: :delete_all), primary_key: true
      add :filter_data, :tsvector
    end

    # create helper function
    execute """
    CREATE FUNCTION prepare_specialist_filter_data(bigint) RETURNS tsvector AS
    $func$
    DECLARE filter_data tsvector;
    BEGIN
      SELECT to_tsvector('simple', specialist_basic_infos.first_name) ||
             to_tsvector('simple', specialist_basic_infos.last_name) ||
             to_tsvector('simple', specialists.email)
      INTO filter_data
      FROM specialists
      INNER JOIN specialist_basic_infos ON specialist_basic_infos.specialist_id = specialists.id
      WHERE specialists.id = $1;

      RETURN filter_data;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger function
    execute """
    CREATE FUNCTION upsert_specialist_filter_data() RETURNS trigger AS
    $func$
    BEGIN
      INSERT INTO specialist_filter_datas(specialist_id, filter_data)
      VALUES
      (
        NEW.specialist_id,
        prepare_specialist_filter_data(NEW.specialist_id)
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
    CREATE TRIGGER upsert_specialist_filter_data_trigger
    AFTER INSERT OR UPDATE ON specialist_basic_infos FOR EACH ROW
    EXECUTE PROCEDURE upsert_specialist_filter_data();
    """

    # populate table
    execute """
    INSERT INTO specialist_filter_datas
    SELECT specialist_basic_infos.specialist_id,
           to_tsvector('simple', specialist_basic_infos.first_name) ||
           to_tsvector('simple', specialist_basic_infos.last_name) ||
           to_tsvector('simple', specialists.email)
    FROM specialists
    INNER JOIN specialist_basic_infos ON specialist_basic_infos.specialist_id = specialists.id;
    """
  end
end
