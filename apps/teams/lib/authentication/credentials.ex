defmodule Teams.Authentication.Credentials do
  use Postgres.Schema

  schema "team_credentials" do
    field(:identifier, :string)
    field(:encrypted_password, :string)
    field(:team_id, :integer)
    field(:password, :string, virtual: true)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:identifier, :team_id, :password])
    |> encrypt_password()
  end

  defp encrypt_password(changeset) do
    password = Ecto.Changeset.get_change(changeset, :password)

    changeset
    |> Ecto.Changeset.validate_required([:password])
    |> case do
      %{valid?: true} = changeset ->
        changeset
        |> Ecto.Changeset.put_change(:encrypted_password, Pbkdf2.hash_pwd_salt(password))

      changeset ->
        changeset
    end
  end
end
