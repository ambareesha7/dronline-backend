defmodule Admin.USBoard.SecondOpinionRequest do
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

    has_many :assigned_specialists, __MODULE__.AssignedSpecialist,
      foreign_key: :us_board_second_opinion_request_id

    has_one :us_board_second_opinion_request_payment, __MODULE__.Payment,
      foreign_key: :us_board_second_opinion_request_id

    timestamps()
  end

  defmodule AssignedSpecialist do
    use Postgres.Schema
    use Postgres.Service

    @primary_key {:id, :binary_id, autogenerate: true}

    schema "us_board_second_opinion_assigned_specialists" do
      field :specialist_id, :integer
      field :assigned_at, :utc_datetime_usec
      field :accepted_at, :utc_datetime_usec
      field :rejected_at, :utc_datetime_usec
      field :status, Ecto.Enum, values: [:assigned, :accepted, :rejected, :unassigned]

      belongs_to :us_board_second_opinion_request, Admin.USBoard.SecondOpinionRequest,
        type: :binary_id

      timestamps()
    end
  end

  defmodule Payment do
    use Postgres.Schema
    use Postgres.Service

    @primary_key {:id, :binary_id, autogenerate: true}
    @foreign_key_type :binary_id

    schema "us_board_second_opinion_request_payments" do
      field :patient_id, :integer
      field :specialist_id, :integer
      field :team_id, :integer
      field :transaction_reference, :string
      field :payment_method, Ecto.Enum, values: [:telr]
      field :price, Money.Ecto.Composite.Type

      belongs_to :us_board_second_opinion_request, Admin.USBoard.SecondOpinionRequest,
        foreign_key: :us_board_second_opinion_request_id,
        type: :binary_id

      timestamps()
    end
  end
end
