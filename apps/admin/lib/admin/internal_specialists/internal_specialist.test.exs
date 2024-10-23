defmodule Admin.InternalSpecialists.InternalSpecialistTest do
  use Postgres.DataCase, async: true
  import Mockery

  alias Admin.InternalSpecialists.InternalSpecialist

  describe "create/1" do
    test "returns {:ok, internal_specialist} when params are valid" do
      params = %{
        email: "nurse@example.com",
        type: "NURSE"
      }

      assert {:ok, _internal_specialist} = InternalSpecialist.create(params)
    end

    test "returns {:error, changeset} when param is missing" do
      params = %{
        email: "nurse@example.com"
      }

      assert {:error, %Ecto.Changeset{}} = InternalSpecialist.create(params)
    end
  end

  describe "fetch_by_id/1" do
    test "returns right internal specialist" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      {:ok, fetched} = InternalSpecialist.fetch_by_id(specialist.id)

      assert fetched.created_at.timestamp == specialist.inserted_at |> Timex.to_unix()
    end

    test "doesn't return external specialist" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      {:error, :not_found} = InternalSpecialist.fetch_by_id(specialist.id)
    end
  end

  describe "fetch_all/1 - without sorting" do
    test "when next token is missing" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      params = %{"limit" => "1"}

      {:ok, [fetched], nil} = InternalSpecialist.fetch_all(params)
      assert fetched.id == specialist.id
    end

    test "when next token is blank string" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      params = %{"limit" => "1", "next_token" => ""}

      {:ok, [fetched], nil} = InternalSpecialist.fetch_all(params)
      assert fetched.id == specialist.id
    end

    test "when next token is valid" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      next_token =
        encode_next_token(%{"next_id" => specialist.id, "sort_by" => :id, "order" => "asc"})

      params = %{"limit" => "1", "next_token" => next_token}

      {:ok, [fetched], nil} = InternalSpecialist.fetch_all(params)
      assert fetched.id == specialist.id
    end

    test "returns next_token when there's more internal specialists" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      specialist2 = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _basic_info2 = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2.id)

      next_token =
        encode_next_token(%{"next_id" => specialist.id, "sort_by" => :id, "order" => "asc"})

      params = %{"limit" => "1", "next_token" => next_token}

      {:ok, [fetched], new_next_token} = InternalSpecialist.fetch_all(params)
      assert fetched.id == specialist.id
      next_id = new_next_token |> decode_next_token() |> Map.get("next_id")
      assert next_id == specialist2.id
    end

    test "doesn't return external doctors" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      params = %{"limit" => "1"}

      {:ok, [], nil} = InternalSpecialist.fetch_all(params)
    end

    test "returns internal specialists without provided basic_info" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      params = %{"limit" => "1"}

      {:ok, [fetched], nil} = InternalSpecialist.fetch_all(params)
      assert fetched.id == specialist.id
    end

    test "retruns internal specialists with given type" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "GP")

      params = %{"type" => "GP"}
      assert {:ok, [fetched], nil} = InternalSpecialist.fetch_all(params)

      assert fetched.type == :GP
    end
  end

  describe "fetch_all/1 - with sorting" do
    test "sorts by first_name (ASC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "B"
        )

      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "A"
        )

      params = %{"sort_by" => "first_name", "order" => "asc"}

      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{first_name: "A"}, %{first_name: "B"}, %{first_name: nil}] = fetched
    end

    test "sorts by first_name (DESC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "B"
        )

      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "A"
        )

      params = %{"sort_by" => "first_name", "order" => "desc"}

      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{first_name: "B"}, %{first_name: "A"}, %{first_name: nil}] = fetched
    end

    test "sorts by type (ASC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "GP")

      params = %{"sort_by" => "type", "order" => "asc"}

      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{type: :GP}, %{type: :NURSE}] = fetched
    end

    test "sorts by type (DESC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "GP")

      params = %{"sort_by" => "type", "order" => "desc", "next_token" => ""}

      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{type: :NURSE}, %{type: :GP}] = fetched
    end

    test "sorts by status (ASC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      specialist = Authentication.Factory.insert(:verified_specialist, type: "GP")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      params = %{"sort_by" => "status", "order" => "asc", "next_token" => ""}

      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{type: :NURSE}, %{type: :GP}] = fetched
    end

    test "sorts by status (DESC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      specialist = Authentication.Factory.insert(:verified_specialist, type: "GP")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      params = %{"sort_by" => "status", "order" => "desc", "next_token" => ""}

      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{type: :GP}, %{type: :NURSE}] = fetched
    end

    test "pagination works (ASC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "GP")

      params = %{"sort_by" => "type", "order" => "asc", "next_token" => "", "limit" => "2"}

      {:ok, fetched, next_token} = InternalSpecialist.fetch_all(params)
      assert [%{type: :GP}, %{type: :NURSE, id: first_nurse_id}] = fetched

      params = %{params | "next_token" => next_token}
      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{type: :NURSE, id: second_nurse_id}] = fetched

      assert first_nurse_id != second_nurse_id
    end

    test "pagination works for sorting by status (ASC)" do
      _nurse1 = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _nurse2 = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      nurse3 = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse3.id)
      nurse4 = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse4.id)

      params = %{"sort_by" => "status", "order" => "asc", "next_token" => "", "limit" => "1"}

      assert {:ok, fetched, next_token} = InternalSpecialist.fetch_all(params)
      assert [%{type: :NURSE, id: first_nurse_id}] = fetched

      params = %{params | "next_token" => next_token, "limit" => "2"}
      assert {:ok, fetched, next_token} = InternalSpecialist.fetch_all(params)

      assert [%{type: :NURSE, id: second_nurse_id}, %{type: :NURSE, id: third_nurse_id}] = fetched
      assert first_nurse_id != second_nurse_id
      assert nurse3.id == third_nurse_id

      params = %{params | "next_token" => next_token, "limit" => "2"}
      assert {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)

      assert [%{type: :NURSE, id: fourth_nurse_id}] = fetched
      assert nurse4.id == fourth_nurse_id
    end

    test "pagination works (DESC)" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "GP")

      params = %{"sort_by" => "type", "order" => "desc", "next_token" => "", "limit" => "1"}

      {:ok, fetched, next_token} = InternalSpecialist.fetch_all(params)
      assert [%{type: :NURSE, id: first_nurse_id}] = fetched

      params = %{params | "next_token" => next_token}
      {:ok, fetched, next_token} = InternalSpecialist.fetch_all(params)
      assert [%{type: :NURSE, id: second_nurse_id}] = fetched

      assert first_nurse_id != second_nurse_id

      params = %{params | "next_token" => next_token}
      {:ok, fetched, nil} = InternalSpecialist.fetch_all(params)
      assert [%{type: :GP, id: _second_nurse_id}] = fetched
    end

    test "pagination works if basic info is missing" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      params = %{"sort_by" => "first_name", "order" => "desc", "next_token" => "", "limit" => "1"}

      assert {:ok, [_fetched], next_token} = InternalSpecialist.fetch_all(params)

      params = %{"next_token" => next_token, "limit" => "1"}
      assert {:ok, [_fetched], nil} = InternalSpecialist.fetch_all(params)
    end

    test "pagination works if there are not completed accounts is missing" do
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      params = %{"sort_by" => "status", "order" => "desc", "next_token" => "", "limit" => "1"}

      assert {:ok, [_fetched], next_token} = InternalSpecialist.fetch_all(params)

      params = %{"next_token" => next_token, "limit" => "1"}
      assert {:ok, [_fetched], nil} = InternalSpecialist.fetch_all(params)
    end

    test "filters result by provided data in filter param" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "first_name"
        )

      _specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      assert {:ok, [fetched_external], nil} =
               InternalSpecialist.fetch_all(%{"filter" => "first_name"})

      assert fetched_external.id == specialist.id
    end
  end

  describe "create_password_recovery_token/1" do
    test "creates password_recovery_token" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      {:ok, specialist} = Postgres.Repo.fetch(InternalSpecialist, specialist.id)

      {:ok, updated_specialist} = InternalSpecialist.create_password_recovery_token(specialist)

      assert updated_specialist.password_recovery_token
    end

    test "loops on password_recovery_token unique constraint error" do
      other_specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      {:ok, other_specialist} = Postgres.Repo.fetch(InternalSpecialist, other_specialist.id)

      {:ok, other_specialist} =
        InternalSpecialist.create_password_recovery_token(other_specialist)

      mock(Admin.Random, [url_safe: 1], fn _ ->
        mock(Admin.Random, [url_safe: 1], fn _ ->
          Admin.Random.url_safe()
        end)

        other_specialist.password_recovery_token
      end)

      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      {:ok, specialist} = Postgres.Repo.fetch(InternalSpecialist, specialist.id)

      {:ok, updated_specialist} = InternalSpecialist.create_password_recovery_token(specialist)

      assert updated_specialist.password_recovery_token
    end

    defp encode_next_token(next_token) do
      next_token
      |> :erlang.term_to_binary()
      |> Base.url_encode64()
    end

    defp decode_next_token(next_token) do
      next_token
      |> Base.url_decode64!()
      |> :erlang.binary_to_term([:safe])
    end
  end
end
