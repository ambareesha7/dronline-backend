defmodule Membership.Telr.GatewayFixtures do
  def check_authorised do
    response = %{
      "method" => "check",
      "trace" => "4000/22752/5c125b4f",
      "order" => %{
        "ref" => "4434634BF74529B014E69793A39D59573DA2640D57049C2B02989634989F93E1",
        "cartid" => "e4e401ab84464c3789be7ff8dbeaa6aa",
        "test" => 1,
        "amount" => "800.00",
        "currency" => "AED",
        "description" => "Payment for DrOnline service - Platinum package",
        "status" => %{
          "code" => 2,
          "text" => "Authorised"
        },
        "transaction" => %{
          "ref" => "030019798960",
          "type" => "auth",
          "class" => "ECom",
          "status" => "H",
          "code" => "922594",
          "message" => "Authorised"
        },
        "agreement" => %{
          "id" => 100_113,
          "initial" => "800.00",
          "recurring" => %{
            "period" => "M",
            "interval" => 1,
            "day" => 13,
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
            "year" => 2023
          }
        },
        "customer" => %{
          "email" => "specialist@example.com",
          "name" => %{
            "forenames" => "test",
            "surname" => "authorised"
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

  def check_declined do
    response = %{
      "method" => "check",
      "trace" => "4001/21520/5c125cbc",
      "order" => %{
        "ref" => "54FF6C2118D8ADE18C62AAE084DACCB69FE83DE810BF607DAE85049CF6366B24",
        "cartid" => "aa8f6a8bc3714f9d8e619d080de09bd4",
        "test" => 1,
        "amount" => "800.00",
        "currency" => "AED",
        "description" => "Payment for DrOnline service - Platinum package",
        "status" => %{
          "code" => -3,
          "text" => "Declined"
        },
        "transaction" => %{
          "ref" => "040019442087",
          "type" => "sale",
          "class" => "ECom",
          "status" => "E",
          "code" => "11",
          "message" => "Invalid card number"
        },
        "customer" => %{
          "email" => "specialist@example.com",
          "name" => %{
            "forenames" => "reject",
            "surname" => "test"
          },
          "address" => %{
            "line1" => "ulica 321",
            "city" => "Poznan",
            "country" => "BN"
          }
        }
      }
    }

    {:ok, response}
  end

  def check_paid do
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

  def check_pending do
    response = %{
      "method" => "check",
      "trace" => "4001/19367/5c125bd7",
      "order" => %{
        "ref" => "54FF6C2118D8ADE18C62AAE084DACCB69FE83DE810BF607DAE85049CF6366B24",
        "url" =>
          "https://secure.telr.com/gateway/process.html?o=54FF6C2118D8ADE18C62AAE084DACCB69FE83DE810BF607DAE85049CF6366B24",
        "cartid" => "aa8f6a8bc3714f9d8e619d080de09bd4",
        "test" => 1,
        "amount" => "800.00",
        "currency" => "AED",
        "description" => "Payment for DrOnline service - Platinum package",
        "status" => %{
          "code" => 1,
          "text" => "Pending"
        }
      }
    }

    {:ok, response}
  end
end
