defmodule Membership.Telr.GatewayMock do
  def send(%{"method" => "create"}) do
    response = %{
      "method" => "create",
      "order" => %{
        "ref" => "OrderRef",
        "url" => "https://secure.telr.com/gateway/process.html?o=OrderRef"
      }
    }

    {:ok, response}
  end

  def send(%{"method" => "check"}) do
    response = %{
      "method" => "check",
      "trace" => "4001/25848/5c10d38f",
      "order" => %{
        "ref" => "3FA8AE2732AB99F958EDB5092055528C3E805296C076AC81B68D9461BA0DC262",
        "cartid" => "2699e4b9384845f3ba8c1abe0b14d2e5",
        "test" => 1,
        "amount" => "800.00",
        "currency" => "AED",
        "description" => "Payment for DrOnline service - Platinum package",
        "status" => %{
          "code" => 3,
          "text" => "Paid"
        },
        "transaction" => %{
          "ref" => "040019403308",
          "type" => "sale",
          "class" => "ECom",
          "status" => "A",
          "code" => "914921",
          "message" => "Authorised"
        },
        "agreement" => %{
          "id" => 99934,
          "initial" => "800.00",
          "recurring" => %{
            "period" => "M",
            "interval" => 1,
            "day" => 12,
            "count" => 0,
            "amount" => "800.00"
          },
          "final" => "0.00"
        },
        "paymethod" => "Card",
        "card" => %{
          "type" => "Visa Credit",
          "last4" => "0002",
          "country" => "AD",
          "first6" => "400000",
          "expiry" => %{
            "month" => 1,
            "year" => 2027
          }
        },
        "customer" => %{
          "email" => "specialist@example.com",
          "name" => %{
            "forenames" => "nsdnai",
            "surname" => "ndian"
          },
          "address" => %{
            "line1" => "ulica 321",
            "city" => "Poznan",
            "country" => "AD"
          }
        }
      }
    }

    {:ok, response}
  end
end
