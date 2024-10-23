defmodule Membership.Telr.ToolsMock do
  def cancel_agreement(_id) do
    response = %{
      "agreement" => %{
        "billing" => %{
          "addr1" => "ulica 321",
          "addr2" => %{},
          "addr3" => %{},
          "city" => "Poznan",
          "country" => "United Arab Emirates",
          "country_iso" => "AE",
          "email" => "specialist@example.com",
          "fname" => "daj",
          "fullname" => "daj bjkda",
          "region" => %{},
          "sname" => "bjkda",
          "tel" => %{},
          "title" => %{},
          "zip" => %{}
        },
        "created" => "Thu, 06 Dec 2018 15:18:47 +0000",
        "currency" => "AED",
        "custid" => %{},
        "description" => "Dh800.00 every month",
        "final" => "0.00",
        "id" => "99667",
        "initial" => "800.00",
        "recurring" => %{
          "amount" => "800.00",
          "count" => "0",
          "day" => "6",
          "interval" => "1",
          "period" => "M"
        },
        "status" => "5",
        "statustxt" => "Cancelled",
        "store" => %{"id" => "21302", "name" => "DRONLINE"},
        "transaction" => %{
          "cartid" => "697eb3174d1c4763852248d947de0bd5",
          "description" => "Payment for DrOnline service - Platinum package",
          "test" => "1"
        }
      }
    }

    {:ok, response}
  end
end
