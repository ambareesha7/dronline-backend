defmodule EMR.PatientInvitations.PatientInvitation do
  use Postgres.Schema
  use Postgres.Service

  alias Postgres.Seeds.Country

  alias __MODULE__

  schema "patient_invitations" do
    field :email, :string
    field :phone_number, :string
    field :specialist_id, :integer

    timestamps()
  end

  @fields [:email, :phone_number]
  defp create_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    # accepts a phone number which contains '+' followed by digits
    |> validate_format(:phone_number, ~r/\+\d+/)
    |> validate_format(:email, ~r/@/)
    |> validate_required_inclusion([:phone_number, :email])
  end

  @spec create(pos_integer, map) :: {:ok, %PatientInvitation{}} | {:error, Ecto.Changeset.t()}
  def create(specialist_id, params) do
    params = prune_phone_number(params)

    existing_invitation =
      PatientInvitation
      |> filter_by_email(params[:email])
      |> filter_by_phone_number(params[:phone_number])
      |> Repo.one()

    existing_invitation
    |> Kernel.||(%PatientInvitation{specialist_id: specialist_id})
    |> create_changeset(params)
    |> Repo.insert_or_update()
  end

  @doc """
  Additional uniq_by is used, because there can be duplicates in database, for example:
  phone | email    | specialist_id
  +1234   same@com   1
  +1234   same@com   1
  +1234   same@com   1
  uniq_by will prevent multiple PATIENT_ACCEPTED_INVITATION emails from being sent to same Specialist.
  """
  @spec fetch_by_phone_number_or_email(String.t(), String.t()) :: list()
  def fetch_by_phone_number_or_email(phone_number, email) do
    PatientInvitation
    |> filter_by_phone_number(phone_number)
    |> filter_by_email(email)
    |> Repo.all()
    |> Enum.uniq_by(& &1.specialist_id)
  end

  defp filter_by_email(query, email) when is_nil(email) or email == "",
    do: or_where(query, [i], is_nil(i.email))

  defp filter_by_email(query, email),
    do: or_where(query, [i], i.email == ^email)

  defp filter_by_phone_number(query, phone_number)
       when is_nil(phone_number) or phone_number == "",
       do: where(query, [i], is_nil(i.phone_number))

  defp filter_by_phone_number(query, phone_number),
    do: where(query, [i], i.phone_number == ^phone_number)

  defp prune_phone_number(%{phone_number: "+" <> phone_number} = params) do
    Country
    |> where(dial_code: ^phone_number)
    |> Repo.one()
    |> case do
      nil -> params
      _ -> %{params | phone_number: nil}
    end
  end

  defp prune_phone_number(params), do: params

  defp validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, &present?(changeset, &1)) do
      changeset
    else
      # Add the error to the first field only since Ecto requires a field name for each error.
      add_error(changeset, hd(fields), "at least one field is required")
    end
  end

  defp present?(changeset, field) do
    value = get_field(changeset, field)
    value && value != ""
  end
end
