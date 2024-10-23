defmodule Admin.USBoard do
  import Ecto.Query

  alias Admin.USBoard.SecondOpinionRequest
  alias Admin.USBoard.SecondOpinionRequest.AssignedSpecialist
  alias Admin.USBoard.Specialist
  alias Postgres.Repo

  def fetch_all_second_opinions_requests do
    query =
      from r in SecondOpinionRequest,
        preload: [
          :us_board_second_opinion_request_payment,
          :assigned_specialists
        ],
        order_by: [desc: r.inserted_at]

    Repo.all(query)
  end

  def fetch_second_opinion_request(request_id) do
    query =
      from r in SecondOpinionRequest,
        where: r.id == ^request_id,
        preload: [
          :us_board_second_opinion_request_payment,
          :assigned_specialists
        ]

    Repo.one(query)
  end

  def fetch_all_us_board_specialists do
    us_board_category_id_query =
      from mc in "medical_categories", where: mc.name == "U.S Board Second Opinion", select: mc.id

    us_board_category_id = Repo.one(us_board_category_id_query)

    specialists_query =
      from s in Specialist,
        join: smc in "specialists_medical_categories",
        on: s.specialist_id == smc.specialist_id,
        join: mc in "medical_categories",
        on: smc.medical_category_id == mc.id,
        where: mc.id == ^us_board_category_id or mc.parent_category_id == ^us_board_category_id,
        order_by: s.last_name,
        distinct: true

    Repo.all(specialists_query)
  end

  def fetch_specialists_history_for_requests(request_ids) do
    AssignedSpecialist
    |> where([as], as.us_board_second_opinion_request_id in ^request_ids)
    |> order_by(desc: :assigned_at)
    |> Repo.all()
    |> Enum.group_by(& &1.us_board_second_opinion_request_id)
  end
end
