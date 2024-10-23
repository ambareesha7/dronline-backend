defmodule Postgres.Repo do
  use Ecto.Repo,
    otp_app: :postgres,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, only: [limit: 2]

  @doc """
  Dynamically loads the repository url from the DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @spec fetch(queryable :: Ecto.Queryable.t(), id :: integer | String.t(), opts :: Keyword.t()) ::
          {:ok, Ecto.Schema.t()}
          | {:error, :not_found}
  def fetch(queryable, id, opts \\ []) do
    case get(queryable, id, opts) do
      nil ->
        {:error, :not_found}

      value ->
        {:ok, value}
    end
  end

  @spec fetch_by(
          queryable :: Ecto.Queryable.t(),
          clauses :: Keyword.t() | map,
          opts :: Keyword.t()
        ) ::
          {:ok, Ecto.Schema.t()}
          | {:error, :not_found}
  def fetch_by(queryable, clauses, opts \\ []) do
    case get_by(queryable, clauses, opts) do
      nil ->
        {:error, :not_found}

      value ->
        {:ok, value}
    end
  end

  @spec fetch_one(queryable :: Ecto.Queryable.t(), opts :: Keyword.t()) ::
          {:ok, any}
          | {:error, :not_found}
  def fetch_one(queryable, opts \\ []) do
    case one(queryable, opts) do
      nil ->
        {:error, :not_found}

      value ->
        {:ok, value}
    end
  end

  @spec fetch_all(queryable :: Ecto.Queryable.t(), opts :: Keyword.t()) :: {:ok, [any]}
  def fetch_all(queryable, opts \\ []) do
    queryable
    |> all(opts)
    |> (&{:ok, &1}).()
  end

  @spec fetch_paginated(
          queryable :: Ecto.Queryable.t(),
          params :: map,
          token_type :: atom | tuple | nil
        ) ::
          {:ok, [Ecto.Schema.t()], term | nil}
  def fetch_paginated(queryable, params, token_type \\ nil) do
    limit = Postgres.Option.parse_limit(params)

    queryable
    |> limit(^(limit + 1))
    |> all()
    |> Enum.split(limit)
    |> case do
      {resp, [token_resource]} ->
        if is_nil(token_type) do
          {:ok, resp, token_resource}
        else
          raw_token = pagination_token_value(token_type, token_resource)

          {:ok, resp, raw_token}
        end

      {resp, []} ->
        {:ok, resp, nil}
    end
  end

  defp pagination_token_value({first, second}, token_resource) do
    token_resource |> Map.get(first) |> Map.get(second)
  end

  defp pagination_token_value(token_type, token_resource) do
    Map.get(token_resource, token_type)
  end
end
