defmodule Membership.Telr.ToolsFixtures do
  def get_agreement_active do
    response = %{
      "agreement" => %{
        "billing" => %{
          "addr1" => "ulica 321",
          "addr2" => %{},
          "addr3" => %{},
          "city" => "Poznan",
          "country" => "Andorra",
          "country_iso" => "AD",
          "email" => "specialist@example.com",
          "fname" => "nsdnai",
          "fullname" => "nsdnai ndian",
          "region" => %{},
          "sname" => "ndian",
          "tel" => %{},
          "title" => %{},
          "zip" => %{}
        },
        "created" => "Tue, 11 Dec 2018 09:29:22 +0000",
        "currency" => "AED",
        "custid" => %{},
        "description" => "Dh800.00 every month",
        "final" => "0.00",
        "id" => "99934",
        "initial" => "800.00",
        "recurring" => %{
          "amount" => "800.00",
          "count" => "0",
          "day" => "12",
          "interval" => "1",
          "period" => "M"
        },
        "status" => "1",
        "statustxt" => "Active",
        "store" => %{"id" => "21302", "name" => "DRONLINE"},
        "transaction" => %{
          "cartid" => "2699e4b9384845f3ba8c1abe0b14d2e5",
          "description" => "Payment for DrOnline service - Platinum package",
          "test" => "1"
        }
      }
    }

    {:ok, response}
  end

  def get_agreement_cancelled do
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
          "fname" => "test",
          "fullname" => "test testowy",
          "region" => %{},
          "sname" => "testowy",
          "tel" => %{},
          "title" => %{},
          "zip" => %{}
        },
        "created" => "Wed, 05 Dec 2018 14:30:09 +0000",
        "currency" => "AED",
        "custid" => %{},
        "description" => "Dh800.00 every month",
        "final" => "0.00",
        "id" => "99603",
        "initial" => "800.00",
        "recurring" => %{
          "amount" => "800.00",
          "count" => "0",
          "day" => "5",
          "interval" => "1",
          "period" => "M"
        },
        "status" => "5",
        "statustxt" => "Cancelled",
        "store" => %{"id" => "21302", "name" => "DRONLINE"},
        "transaction" => %{
          "cartid" => "527e27bf6a704b0b9d5d636a91c59ba8",
          "description" => "xxx",
          "test" => "1"
        }
      }
    }

    {:ok, response}
  end

  def get_agreement_failed do
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
          "fname" => "test",
          "fullname" => "test testowy",
          "region" => %{},
          "sname" => "testowy",
          "tel" => %{},
          "title" => %{},
          "zip" => %{}
        },
        "created" => "Wed, 05 Dec 2018 14:30:09 +0000",
        "currency" => "AED",
        "custid" => %{},
        "description" => "Dh800.00 every month",
        "final" => "0.00",
        "id" => "99603",
        "initial" => "800.00",
        "recurring" => %{
          "amount" => "800.00",
          "count" => "0",
          "day" => "5",
          "interval" => "1",
          "period" => "M"
        },
        "status" => "3",
        "statustxt" => "Failed",
        "store" => %{"id" => "21302", "name" => "DRONLINE"},
        "transaction" => %{
          "cartid" => "527e27bf6a704b0b9d5d636a91c59ba8",
          "description" => "xxx",
          "test" => "1"
        }
      }
    }

    {:ok, response}
  end

  def get_agreement_history_not_paid do
    response = %{
      "agreement" => %{
        "event" => [
          %{
            "date" => "Tue, 11 Dec 2018 09:31:53 +0000",
            "type" => "1",
            "typetxt" => "Agreement created"
          },
          %{
            "amount" => "800.00",
            "date" => "Tue, 11 Dec 2018 09:31:53 +0000",
            "paytype" => "1",
            "paytypetxt" => "Initial",
            "tranref" => "030019759949",
            "type" => "7",
            "typetxt" => "Transaction authorised"
          },
          %{
            "amount" => "800.00",
            "date" => "Wed, 12 Dec 2018 04:30:41 +0000",
            "paycount" => "1",
            "paytype" => "2",
            "paytypetxt" => "Installment",
            "tranref" => "090000015801",
            "type" => "8",
            "typetxt" => "Transaction declined"
          }
        ],
        "eventcount" => "4",
        "id" => "99935"
      }
    }

    {:ok, response}
  end

  def get_agreement_history_paid do
    response = %{
      "agreement" => %{
        "event" => [
          %{
            "date" => "Tue, 11 Dec 2018 09:29:22 +0000",
            "type" => "1",
            "typetxt" => "Agreement created"
          },
          %{
            "amount" => "800.00",
            "date" => "Tue, 11 Dec 2018 09:29:22 +0000",
            "paytype" => "1",
            "paytypetxt" => "Initial",
            "tranref" => "040019403308",
            "type" => "7",
            "typetxt" => "Transaction authorised"
          },
          %{
            "amount" => "800.00",
            "date" => "Wed, 12 Dec 2018 04:30:41 +0000",
            "paycount" => "1",
            "paytype" => "2",
            "paytypetxt" => "Installment",
            "tranref" => "090000015800",
            "type" => "7",
            "typetxt" => "Transaction authorised"
          }
        ],
        "eventcount" => "3",
        "id" => "99934"
      }
    }

    {:ok, response}
  end
end
