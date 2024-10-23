defmodule Postgres.Repo.Migrations.UpdateTableAndTriggersForPatientFiltering do
  use Ecto.Migration

  def up do
    # cleanup old filters
    execute "DROP TRIGGER upsert_user_filter_data_trigger ON user_addresses;"
    execute "DROP TRIGGER upsert_user_filter_data_trigger ON user_basic_infos;"
    execute "DROP FUNCTION upsert_user_filter_data();"
    execute "DROP FUNCTION prepare_user_filter_data(bigint);"
    drop table(:user_filter_datas)

    # create new ones
    create table(:user_filter_datas, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :filter_data, :tsvector
    end

    # create helper function
    execute """
    CREATE FUNCTION prepare_user_filter_data(bigint) RETURNS tsvector AS
    $func$
    DECLARE filter_data tsvector;
    BEGIN
      SELECT to_tsvector('simple', user_basic_infos.first_name) ||
             to_tsvector('simple', user_basic_infos.last_name) ||
             to_tsvector('simple', users.phone_number)
      INTO filter_data
      FROM users
      INNER JOIN user_basic_infos ON user_basic_infos.user_id = users.id
      WHERE users.id = $1;

      RETURN filter_data;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger function
    execute """
    CREATE FUNCTION upsert_user_filter_data() RETURNS trigger AS
    $func$
    BEGIN
      INSERT INTO user_filter_datas(user_id, filter_data)
      VALUES
      (
        NEW.user_id,
        prepare_user_filter_data(NEW.user_id)
      )
      ON CONFLICT (user_id)
      DO
        UPDATE
          SET filter_data = EXCLUDED.filter_data;

      RETURN NEW;
    END
    $func$ LANGUAGE plpgsql;
    """

    # create trigger on user_basic_infos
    execute """
    CREATE TRIGGER upsert_user_filter_data_trigger
    AFTER INSERT OR UPDATE ON user_basic_infos FOR EACH ROW
    EXECUTE PROCEDURE upsert_user_filter_data();
    """

    # populate table
    execute """
    INSERT INTO user_filter_datas
    SELECT user_basic_infos.user_id,
           to_tsvector('simple', user_basic_infos.first_name) ||
           to_tsvector('simple', user_basic_infos.last_name) ||
           to_tsvector('simple', users.phone_number)
    FROM users
    INNER JOIN user_basic_infos ON user_basic_infos.user_id = users.id;
    """
  end

  def down do
    execute "DROP TRIGGER upsert_user_filter_data_trigger ON user_basic_infos;"
    execute "DROP FUNCTION upsert_user_filter_data();"
    execute "DROP FUNCTION prepare_user_filter_data(bigint);"
    drop table(:user_filter_datas)
  end
end
