defmodule Membership.Packages do
  @type package :: %{
          name: String.t(),
          price: float(),
          features: [Proto.Membership.Package.Feature.t()],
          type: String.t(),
          included_features: [Proto.Membership.Package.Feature.t()],
          missing_features: [Proto.Membership.Package.Feature.t()]
        }

  @packages [
    %{
      name: "Basic",
      price: 0,
      features: [
        %Proto.Membership.Package.Feature{
          text: "Profile visible to patients",
          description:
            "Bascially your profile is visible to patients while scheduling appointments, follow up or checkups."
        },
        %Proto.Membership.Package.Feature{text: "Requests & consultation"},
        %Proto.Membership.Package.Feature{text: "Listed in a speciality"},
        %Proto.Membership.Package.Feature{
          text: "Patient referrals",
          description:
            "Get patient referrals from DrOnline while providing your availability online."
        }
      ],
      type: "BASIC",
      included_features: [
        %Proto.Membership.Package.Feature{
          text: "Profile visible to patients",
          description:
            "Bascially your profile is visible to patients while scheduling appointments, follow up or checkups."
        },
        %Proto.Membership.Package.Feature{text: "Requests & consultation"},
        %Proto.Membership.Package.Feature{text: "Listed in a speciality"},
        %Proto.Membership.Package.Feature{
          text: "Patient referrals",
          description:
            "Get patient referrals from DrOnline while providing your availability online."
        }
      ],
      missing_features: [
        %Proto.Membership.Package.Feature{text: "Featured on home screen"},
        %Proto.Membership.Package.Feature{text: "Featured at the top of list in a speciality"},
        %Proto.Membership.Package.Feature{text: "Electronic Medical Records"},
        %Proto.Membership.Package.Feature{
          text: "Conceirge triage support activation",
          description:
            "Allowing you to dispatch triage units directly to their patients at anytime."
        },
        %Proto.Membership.Package.Feature{text: "One on one video visits with patients"},
        %Proto.Membership.Package.Feature{
          text: "Priority on our referrals",
          description:
            "You're being prioritized on our referrals from DrOnline network of patients."
        }
      ]
    },
    %{
      name: "Silver",
      price: 99.00,
      features: [
        %Proto.Membership.Package.Feature{text: "All Basic features", bold: true},
        %Proto.Membership.Package.Feature{text: "Ordering medication"}
      ],
      type: "SILVER",
      included_features: [
        %Proto.Membership.Package.Feature{
          text: "Profile visible to patients",
          description:
            "Bascially your profile is visible to patients while scheduling appointments, follow up or checkups."
        },
        %Proto.Membership.Package.Feature{text: "Requests & consultation"},
        %Proto.Membership.Package.Feature{text: "Listed in a speciality"},
        %Proto.Membership.Package.Feature{
          text: "Patient referrals",
          description:
            "Get patient referrals from DrOnline while providing your availability online."
        },
        %Proto.Membership.Package.Feature{text: "Ordering medication"}
      ],
      missing_features: [
        %Proto.Membership.Package.Feature{text: "Electronic Medical Records"},
        %Proto.Membership.Package.Feature{
          text: "Conceirge triage support activation",
          description:
            "Allowing you to dispatch triage units directly to their patients at anytime."
        },
        %Proto.Membership.Package.Feature{text: "One on one video visits with patients"},
        %Proto.Membership.Package.Feature{
          text: "Priority on our referrals",
          description:
            "You're being prioritized on our referrals from DrOnline network of patients."
        }
      ]
    },
    %{
      name: "Gold",
      price: 159.00,
      features: [
        %Proto.Membership.Package.Feature{text: "All Silver features", bold: true},
        %Proto.Membership.Package.Feature{text: "Electronic Medical Records"},
        %Proto.Membership.Package.Feature{
          text: "Conceirge triage support activation",
          description:
            "Allowing you to dispatch triage units directly to their patients at anytime."
        }
      ],
      type: "GOLD",
      included_features: [
        %Proto.Membership.Package.Feature{
          text: "Profile visible to patients",
          description:
            "Bascially your profile is visible to patients while scheduling appointments, follow up or checkups."
        },
        %Proto.Membership.Package.Feature{text: "Requests & consultation"},
        %Proto.Membership.Package.Feature{text: "Listed in a speciality"},
        %Proto.Membership.Package.Feature{
          text: "Patient referrals",
          description:
            "Get patient referrals from DrOnline while providing your availability online."
        },
        %Proto.Membership.Package.Feature{text: "Featured on home screen"},
        %Proto.Membership.Package.Feature{text: "Featured at the top of list in a speciality"},
        %Proto.Membership.Package.Feature{text: "Electronic Medical Records"},
        %Proto.Membership.Package.Feature{
          text: "Conceirge triage support activation",
          description:
            "Allowing you to dispatch triage units directly to their patients at anytime."
        }
      ],
      missing_features: [
        %Proto.Membership.Package.Feature{text: "One on one video visits with patients"},
        %Proto.Membership.Package.Feature{
          text: "Priority on our referrals",
          description:
            "You're being prioritized on our referrals from DrOnline network of patients."
        }
      ]
    },
    %{
      name: "Platinum",
      price: 199.00,
      features: [
        %Proto.Membership.Package.Feature{text: "All Gold features", bold: true},
        %Proto.Membership.Package.Feature{text: "Patient escort service"},
        %Proto.Membership.Package.Feature{text: "Diagnostic testing"},
        %Proto.Membership.Package.Feature{text: "Access to Our Home healthcare services"},
        %Proto.Membership.Package.Feature{
          text: "Priority on our referrals",
          description:
            "You're being prioritized on our referrals from DrOnline network of patients."
        }
      ],
      type: "PLATINUM",
      included_features: [
        %Proto.Membership.Package.Feature{text: "Patient escort service"},
        %Proto.Membership.Package.Feature{text: "Diagnostic testing"},
        %Proto.Membership.Package.Feature{text: "Ordering medication"},
        %Proto.Membership.Package.Feature{text: "Access to Our Home healthcare services"},
        %Proto.Membership.Package.Feature{text: "Featured on home screen"},
        %Proto.Membership.Package.Feature{text: "Featured at the top of list in a speciality"},
        %Proto.Membership.Package.Feature{text: "Electronic Medical Records"},
        %Proto.Membership.Package.Feature{
          text: "Priority on our referrals",
          description:
            "You're being prioritized on our referrals from DrOnline network of patients."
        }
      ],
      missing_features: []
    }
  ]

  @spec fetch_all() :: {:ok, [package, ...]}
  def fetch_all, do: {:ok, @packages}

  @spec fetch_one(String.t()) :: {:ok, package} | {:error, :not_found}
  def fetch_one(type) do
    @packages
    |> Enum.find(fn package ->
      package.type == type
    end)
    |> case do
      nil -> {:error, :not_found}
      package -> {:ok, package}
    end
  end
end
