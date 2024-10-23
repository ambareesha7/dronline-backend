defmodule Web.Router do
  use Web, :router

  use Sentry.PlugCapture

  require Web.Routes.AuthenticatedAdminApi
  require Web.Routes.AuthenticatedPanelApi
  require Web.Routes.AuthenticatedPatientApi

  pipeline :api do
    plug Plug.Logger
    plug :accepts, ["proto"]
    plug Web.Plugs.ResponseMetrics
    plug Web.Plugs.SentryUserContext
  end

  pipeline :mounted_apps do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  pipeline :authenticate_patient do
    plug Web.Plugs.AuthenticatePatient
    plug Web.Plugs.SentryUserContext
  end

  pipeline :authenticate_specialist do
    plug Web.Plugs.AuthenticateSpecialist
    plug Web.Plugs.SentryUserContext
  end

  pipeline :authenticate_admin do
    plug Web.Plugs.AuthenticateAdmin
    plug Web.Plugs.SentryUserContext
  end

  pipeline :pdf do
    plug Plug.Logger
    plug :accepts, ["pdf"]
  end

  pipeline :webhook do
    plug Plug.Logger
    plug :accepts, ["json"]
    plug Web.Plugs.ResponseMetrics
  end

  # health check
  scope "/", Web do
    get "/ping", PingController, :ping
  end

  scope "/public_api", Web.PublicApi do
    pipe_through :api

    get "/countries", CountriesController, :index
    get "/feature_flags/verify/:flag_name", FeatureFlagsController, :verify

    get "/calls/family_member_invitations/:id",
        FamilyMemberInvitationsController,
        :show
  end

  scope "/admin_api", Web.AdminApi, as: :admin do
    pipe_through :api

    post "/login", AuthController, :login

    # TODO: REMOVE THIS ROUTES
    # post "/upload_meds", MedicationsController, :uploads
    # post "/delete_all_meds", MedicationsController, :delete_all_meds
    # get "/get_all_meds", MedicationsController, :get_all_meds
  end

  # authenticated admin api
  scope "/admin_api", Web.AdminApi, as: :admin do
    pipe_through [:api, :authenticate_admin]

    Web.Routes.AuthenticatedAdminApi.routes()
  end

  scope path: "/feature_flags_ui" do
    pipe_through :mounted_apps
    forward "/", FunWithFlags.UI.Router, namespace: "feature_flags_ui"
  end

  # public /api
  scope "/api", Web.Api do
    pipe_through :api

    get "/insurance_providers", InsuranceProvidersController, :index

    post "/login", AuthController, :login

    post "/newsletter", NewsletterController, :subscribe
  end

  # authenticated patient api
  scope "/api", Web.Api do
    pipe_through [:api, :authenticate_patient]

    Web.Routes.AuthenticatedPatientApi.routes()
  end

  # authenticated patient pdf api
  scope "/api", Web.Api do
    pipe_through [:pdf, :authenticate_patient]

    scope "/emr", EMR, as: :emr do
      get "/records/:id/pdf", RecordsController, :pdf
    end
  end

  # public panel api
  scope "/panel_api", Web.PanelApi, as: :panel do
    pipe_through :api

    post "/change_password/confirm", AuthController, :confirm_password_change
    post "/login", AuthController, :login
    post "/recover_password", AuthController, :recover_password
    post "/send_password_recovery", AuthController, :send_password_recovery
    post "/signup", AuthController, :signup
    post "/verify", AuthController, :verify
  end

  # authenticated panel api
  scope "/panel_api", Web.PanelApi, as: :panel do
    pipe_through [:api, :authenticate_specialist]

    Web.Routes.AuthenticatedPanelApi.routes()
  end

  # authenticated panel pdf api
  scope "/panel_api", Web.PanelApi, as: :panel do
    pipe_through [:pdf, :authenticate_specialist]

    scope "/emr", EMR, as: :emr do
      get "/patients/:patient_id/records/:id/pdf", RecordsController, :pdf
    end
  end

  # landing page api
  scope "/landing_api", Web.LandingApi, as: :landing do
    pipe_through :api

    get "/specialists_search", Specialists.SearchController, :index
    post "/request_second_opinion", USBoardController, :request_second_opinion
    post "/fill_contact_form", USBoardController, :fill_contact_form
    post "/confirm_second_opinion_payment", USBoardController, :confirm_second_opinion_payment
    get "/upload/second_opinion_file_url", FileUploadController, :second_opinion_file_url
    post "/urgent_care_request", UrgentHelpRequestController, :request_urgent_help
  end

  # TODO: move functionality into landing name space and remove this section
  scope "/landing_api", Web.Api.EMR do
    pipe_through :api
    get "/assigned_meds/:order_id", MedicationsController, :fetch_medication_order
    post "/confirm_meds_payment/:status", MedicationsController, :confirm_meds_payment

    # move this routes under authentication
    # get "/fetch_medication_order_for_app/:order_id",
    #     MedicationsController,
    #     :fetch_medication_order_for_app

    # post "/confirm_meds_payment_from_app/:status",
    #      MedicationsController,
    #      :confirm_meds_payment_from_app
  end

  scope "/webhooks", Web.Webhooks, as: :webhooks do
    pipe_through [:webhook]

    post "/tokbox_archive_callback", TokboxArchiveCallbackController, :handle_callback
  end
end
