defmodule Authentication.Specialist.ChangesetHelpers do
  import Mockery.Macro

  @spec generate_token(Ecto.Changeset.t(), atom, pos_integer) :: Ecto.Changeset.t()
  def generate_token(changeset, field, size) do
    changeset |> Ecto.Changeset.put_change(field, mockable(Authentication.Random).url_safe(size))
  end

  @spec handle_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def handle_password(changeset) do
    password = Ecto.Changeset.get_change(changeset, :password)

    changeset
    |> Ecto.Changeset.validate_required([:password])
    |> validate_password()
    |> case do
      %{valid?: true} = changeset ->
        changeset
        |> Ecto.Changeset.put_change(:password_hash, Pbkdf2.hash_pwd_salt(password))

      changeset ->
        changeset
    end
  end

  defp validate_password(changeset) do
    changeset
    |> Ecto.Changeset.validate_length(:password, min: 8)
    |> Ecto.Changeset.validate_format(:password, ~r/\d+/,
      message: "must contain at least 1 digit"
    )
    |> Ecto.Changeset.validate_format(:password, ~r/[a-z]+/,
      message: "must contain at least 1 lowercase character"
    )
    |> Ecto.Changeset.validate_format(:password, ~r/[A-Z]+/,
      message: "must contain at least 1 uppercase character"
    )
    |> Ecto.Changeset.validate_format(:password, ~r/[ !@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/\?]+/,
      message: "must contain at least 1 special character"
    )
  end
end
