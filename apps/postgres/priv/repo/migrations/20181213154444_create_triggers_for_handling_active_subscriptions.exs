defmodule Postgres.Repo.Migrations.CreateTriggersForHandlingActiveSubscriptions do
  use Ecto.Migration

  def up do
    execute """
    CREATE FUNCTION handle_subscription_activation() RETURNS trigger AS
    $func$
    BEGIN
      PERFORM subscriptions.id FROM subscriptions
        WHERE active = true AND specialist_id = NEW.specialist_id AND id <> NEW.id FOR UPDATE;

      IF NOT FOUND THEN
        UPDATE subscriptions SET active = true WHERE id = NEW.id;
        UPDATE specialists SET package_type = NEW.type WHERE id = NEW.specialist_id;
      END IF;

      RETURN NEW;
    END
    $func$ LANGUAGE plpgsql;
    """

    execute """
    CREATE FUNCTION handle_subscription_deactivation() RETURNS trigger AS
    $func$
    DECLARE
    subscription_id_to_activate bigint;
    BEGIN
      UPDATE subscriptions SET active = false WHERE id = NEW.id;

      SELECT id INTO subscription_id_to_activate FROM subscriptions
        WHERE status = 'ACCEPTED' AND specialist_id = NEW.specialist_id FOR UPDATE;

      IF FOUND THEN
        UPDATE subscriptions SET active = true WHERE id = subscription_id_to_activate;
      ELSE
        UPDATE specialists SET package_type = 'BASIC' WHERE id = NEW.specialist_id;
      END IF;

      RETURN NEW;
    END
    $func$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER subscription_activation_trigger
    AFTER UPDATE OF status ON subscriptions FOR EACH ROW WHEN (NEW.status = 'ACCEPTED')
    EXECUTE PROCEDURE handle_subscription_activation();
    """

    execute """
    CREATE TRIGGER subscription_deactivation_trigger
    AFTER UPDATE OF status ON subscriptions FOR EACH ROW WHEN (NEW.status = 'ENDED')
    EXECUTE PROCEDURE handle_subscription_deactivation();
    """
  end

  def down do
    execute "DROP TRIGGER subscription_activation_trigger on subscriptions;"
    execute "DROP TRIGGER subscription_deactivation_trigger on subscriptions;"
    execute "DROP FUNCTION handle_subscription_activation();"
    execute "DROP FUNCTION handle_subscription_deactivation();"
  end
end
