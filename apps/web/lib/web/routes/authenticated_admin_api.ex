defmodule Web.Routes.AuthenticatedAdminApi do
  defmacro routes do
    quote do
      get "/account_deletions", AccountDeletionsController, :index

      resources "/external_specialists", ExternalSpecialistsController, only: [:index, :show]

      scope "/external_specialists", ExternalSpecialists, as: :external_specialists do
        get "/pending_requests", VerificationController, :pending_requests
        get "/latests_approvals", VerificationController, :latests_approvals
      end

      scope "/external_specialists/:specialist_id", ExternalSpecialists, as: :external_specialists do
        post "/verify", VerificationController, :verify
        get "/basic_info", BasicInfoController, :show
        get "/credentials", CredentialsController, :show
        get "/location", LocationController, :show
        get "/medical_credentials", MedicalCredentialsController, :show
        get "/medical_categories", MedicalCategoriesController, :show
      end

      resources "/internal_specialists", InternalSpecialistsController,
        only: [:create, :index, :show]

      scope "/internal_specialists/:specialist_id", InternalSpecialists, as: :internal_specialists do
        resources "/basic_info", BasicInfoController, only: [:show, :update], singleton: true
        resources "/credentials", CredentialsController, only: [:show], singleton: true

        resources "/medical_credentials", MedicalCredentialsController,
          only: [:show, :update],
          singleton: true

        resources "/medical_categories", MedicalCategoriesController,
          only: [:show, :update],
          singleton: true
      end

      scope "/specialists/:specialist_id", Specialists, as: :specialists do
        resources "/bio", BioController, only: [:show, :update], singleton: true
      end

      scope "/upload" do
        get "/profile_image_url", UploadController, :profile_image_url
      end

      scope "/us_board" do
        get "/fetch_requests", USBoardController, :fetch_requests
        get "/fetch_request/:request_id", USBoardController, :fetch_request
        get "/fetch_us_board_specialists", USBoardController, :fetch_us_board_specialists
        post "/assign_specialist", USBoardController, :assign_specialist
      end

      scope "/medical_categories" do
        resources "/", MedicalCategoryController, only: [:index, :update]
      end

      scope "/medications" do
        post "/upload_meds", MedicationsController, :uploads
        post "/delete_all_meds", MedicationsController, :delete_all_meds
        get "/get_all_meds", MedicationsController, :get_all_meds
      end
    end
  end
end
