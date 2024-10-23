defmodule Visits.USBoard.SecondOpinionRequest do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "us_board_second_opinion_requests" do
    field :patient_id, :integer
    field :visit_id, :string
    field :patient_description, :string
    field :specialist_opinion, :string
    field :patient_email, :string

    field :status, Ecto.Enum,
      values: [
        :landing_form,
        :landing_booking,
        :requested,
        :assigned,
        :rejected,
        :in_progress,
        :opinion_submitted,
        :call_scheduled,
        :done,
        :cancelled,
        :landing_payment_pending
      ]

    embeds_many :files, File do
      field :path, :string
    end

    has_many :assigned_specialists, Visits.USBoard.SecondOpinionAssignedSpecialist,
      foreign_key: :us_board_second_opinion_request_id

    has_one :us_board_second_opinion_request_payment, Visits.USBoard.SecondOpinionRequestPayment,
      foreign_key: :us_board_second_opinion_request_id

    timestamps()
  end

  @required [:patient_email]
  @fields @required ++
            [:patient_id, :visit_id, :patient_description, :specialist_opinion, :status]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> cast_embed(:files, with: &files_changeset/2)
  end

  def update_specialist_opinion(
        request_id,
        specialist_opinion
      ) do
    with {:ok, request} <- fetch(request_id) do
      request
      |> changeset(%{specialist_opinion: specialist_opinion})
      |> Repo.update()
    else
      error ->
        error
    end
  end

  defp files_changeset(schema, params) do
    schema
    |> cast(params, [:path])
  end

  defp fetch(id) do
    __MODULE__
    |> where(id: ^id)
    |> Repo.fetch_one()
  end
end
