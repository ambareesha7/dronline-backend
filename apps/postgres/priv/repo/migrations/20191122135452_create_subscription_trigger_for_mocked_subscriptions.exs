defmodule Postgres.Repo.Migrations.CreateSubscriptionTriggerForMockedSubscriptions do
  use Ecto.Migration

  def up do
    execute """
    CREATE FUNCTION handle_subscription_change() RETURNS trigger AS
    $func$
    BEGIN
      UPDATE specialists SET package_type = NEW.type WHERE id = NEW.specialist_id;

      RETURN NEW;
    END
    $func$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER subscription_change_trigger
    AFTER INSERT OR UPDATE OF type ON mocked_subscriptions FOR EACH ROW
    EXECUTE PROCEDURE handle_subscription_change();
    """
  end

  def down do
    execute "DROP TRIGGER subscription_change_trigger on mocked_subscriptions;"
    execute "DROP FUNCTION handle_subscription_change();"
  end
end
