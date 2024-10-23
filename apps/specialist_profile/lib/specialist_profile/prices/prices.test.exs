defmodule SpecialistProfile.PricesTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.Prices
  alias SpecialistProfile.Prices.MedicalCategory

  @params %{
    price_minutes_15: 9,
    price_minutes_30: 99,
    price_minutes_45: 999,
    price_minutes_60: 9_999,
    price_second_opinion: 99_999,
    price_in_office: 1000,
    currency: "INR",
    currency_in_office: "INR"
  }

  describe "fetch_by_specialist_id/1" do
    test "returns prices if prices exist for specialist_id" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "medical_category")

      params =
        Map.merge(@params, %{
          specialist_id: specialist.id,
          medical_category_id: medical_category.id
        })

      _prices = SpecialistProfile.Factory.insert(:prices, params)

      assert [
               %Prices{
                 price_minutes_15: 9,
                 medical_category: %MedicalCategory{name: "medical_category"},
                 currency: "INR"
               }
             ] = Prices.fetch_by_specialist_id(specialist.id)
    end

    test "returns [] if prices don't exist for specialist_id" do
      assert [] = Prices.fetch_by_specialist_id(0)
    end
  end

  describe "fetch_by_specialists_id/1" do
    test "returns prices if prices exist for specialists_id" do
      specialist1 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      specialist2 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      specialist1_id = specialist1.id
      specialist2_id = specialist2.id

      medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "medical_category")

      params1 =
        Map.merge(@params, %{
          specialist_id: specialist1.id,
          medical_category_id: medical_category.id,
          currency: "USD"
        })

      params2 =
        Map.merge(@params, %{
          price_minutes_15: 8,
          specialist_id: specialist2.id,
          medical_category_id: medical_category.id
        })

      _prices = SpecialistProfile.Factory.insert(:prices, params1)
      _prices = SpecialistProfile.Factory.insert(:prices, params2)

      fetched_prices =
        [specialist1.id, specialist2.id]
        |> Prices.fetch_by_specialists_id()
        |> Enum.sort_by(& &1.price_minutes_15)

      assert [
               %Prices{
                 price_minutes_15: 8,
                 medical_category: %MedicalCategory{name: "medical_category"},
                 specialist_id: ^specialist2_id,
                 currency: "INR"
               },
               %Prices{
                 price_minutes_15: 9,
                 medical_category: %MedicalCategory{name: "medical_category"},
                 specialist_id: ^specialist1_id,
                 currency: "USD"
               }
             ] = fetched_prices
    end

    test "returns [] if prices don't exist for specialist_id" do
      assert [] = Prices.fetch_by_specialists_id([0])
    end
  end

  describe "update/2" do
    setup do
      medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "medical_category")

      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, %{medical_category_id: medical_category.id, specialist_id: specialist.id}}
    end

    test "creates prices when they don't exist, set's prices enabled to true", setup_params do
      params = Map.merge(%{@params | currency: "USD"}, setup_params)

      assert {:ok,
              %Prices{
                price_minutes_15: 9,
                prices_enabled: true,
                currency: "USD"
              }} = Prices.update(setup_params.specialist_id, params)
    end

    test "updates prices when they exists", setup_params do
      params = Map.merge(@params, setup_params)
      _basic_info = SpecialistProfile.Factory.insert(:prices, params)
      params = put_in(params[:price_minutes_15], 1)
      {:ok, prices} = Prices.update(setup_params.specialist_id, params)

      assert prices.price_minutes_15 == 1
    end

    test "doesn't return error when 15 minutes price is higher then 0", setup_params do
      params =
        Map.merge(
          %{price_minutes_15: 10, currency: "USD", price_in_office: 0, currency_in_office: nil},
          setup_params
        )

      assert {:ok,
              %Prices{
                price_minutes_15: 10,
                currency: "USD",
                price_in_office: 0,
                currency_in_office: nil,
                prices_enabled: true
              }} =
               Prices.update(setup_params.specialist_id, params)
    end

    test "doesn't return error when in-office price is higher then 0", setup_params do
      params =
        Map.merge(
          %{
            price_minutes_15: 0,
            currency: nil,
            price_in_office: 10,
            currency_in_office: "USD"
          },
          setup_params
        )

      assert {:ok,
              %Prices{
                price_minutes_15: 0,
                currency: nil,
                price_in_office: 10,
                currency_in_office: "USD",
                prices_enabled: true
              }} =
               Prices.update(setup_params.specialist_id, params)
    end

    test "returns error when at least one of 15 minutes or in-office prices is not higher then 0",
         setup_params do
      params =
        Map.merge(
          %{price_minutes_15: 0, currency: "USD", price_in_office: 0, currency_in_office: "USD"},
          setup_params
        )

      assert {:error,
              %Ecto.Changeset{
                errors: [price_minutes_15: {"or price_in_office has to be greater than 0", []}]
              }} =
               Prices.update(setup_params.specialist_id, params)
    end

    test "returns error when 15 minutes currency is not choosen with price", setup_params do
      params = Map.merge(%{price_minutes_15: 10, currency: nil}, setup_params)

      assert {:error, %Ecto.Changeset{errors: [currency: {"has to be one of INR, AED, USD", []}]}} =
               Prices.update(setup_params.specialist_id, params)
    end

    test "returns error when in-office currency is not choosen with price", setup_params do
      params = Map.merge(%{price_in_office: 10, currency_in_office: nil}, setup_params)

      assert {:error,
              %Ecto.Changeset{
                errors: [currency_in_office: {"has to be one of INR, AED, USD", []}]
              }} =
               Prices.update(setup_params.specialist_id, params)
    end

    test "returns error changeset when currency is not one of available ones", setup_params do
      params = Map.merge(%{price_minutes_15: 10, currency: "PLN"}, setup_params)

      assert {:error, %Ecto.Changeset{errors: [currency: {"has to be one of INR, AED, USD", []}]}} =
               Prices.update(setup_params.specialist_id, params)
    end
  end
end
