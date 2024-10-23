defmodule Web.Routes.AuthenticatedPatientApi do
  defmacro routes do
    quote do
      scope "/calls", Calls, as: :calls do
        resources "/hpi", HPIController, only: [:show, :update], singleton: true

        resources "/family_member_invitations",
                  FamilyMemberInvitationsController,
                  only: [:create]

        get "/local_clinic", AvailabilityController, :local_clinic
      end

      get "/channels_token", ChannelsTokenController, :show

      post "/delete_account", AccountDeletionController, :delete_account

      put "/devices", DevicesController, :register
      put "/devices/unregister", DevicesController, :unregister

      put "/ios_devices", DevicesController, :register_ios
      put "/ios_devices/unregister", DevicesController, :unregister_ios

      get "/doctors_details", DoctorsController, :doctors_details

      scope "/emr", EMR, as: :emr do
        resources "/records", RecordsController, only: [:index, :show]

        scope "/records/:record_id" do
          get "/call_recordings", CallRecordingsController, :index
          resources "/hpi", HPIController, only: [:show, :update], singleton: true
          get "/hpi/history", HPIController, :history
          # TODO: Refactor to :index instad of :history_for_record
          get "/ordered_tests/history", OrderedTestsController, :history_for_record
          get "/medications/history", MedicationsController, :history_for_record
          get "/medical_summaries", MedicalSummariesController, :index

          get "/ordered_tests/:id", OrderedTestsController, :show
          get "/medications/:id", MedicationsController, :show
          post "/medications/:id/save_payment", MedicationsController, :save_payment
          get "/medical_summaries/:id", MedicalSummariesController, :show

          get "/results/blood_pressure_entries", ResultsController, :blood_pressure_entries
          get "/results/bmi_entries", ResultsController, :bmi_entries
          get "/specialists", SpecialistsController, :index
          get "/visits", VisitsController, :index
          get "/vitals/history", VitalsController, :history_for_record
        end

        get "/vitals", VitalsController, :show
        get "/vitals/history", VitalsController, :history
      end

      get "/featured_doctors", DoctorsController, :featured_doctors
      get "/favourite_providers", DoctorsController, :favourite_providers

      get "/image", ResizeController, :resize

      resources "/medical_categories", MedicalCategoryController, only: [:index, :show] do
        get "/featured_doctors", MedicalCategoryController, :featured_doctors,
          as: :featured_doctors
      end

      scope "/patient", Patient, as: :patient do
        resources "/address", AddressController, only: [:show, :update], singleton: true
        resources "/basic_info", BasicInfoController, only: [:show, :update], singleton: true
        resources "/bmi", BMIController, only: [:show, :update], singleton: true

        resources "/insurance", InsuranceController,
          only: [:show, :update, :delete],
          singleton: true

        resources "/children", ChildController, only: [:index, :create]

        resources "/history", HistoryFormsController, only: [:show, :update], singleton: true

        resources "/review_of_system", ReviewOfSystemController,
          only: [:show, :update],
          singleton: true

        get "/review_of_system/history", ReviewOfSystemController, :history

        get "/status", StatusController, :show

        get "/credentials", CredentialsController, :show, singleton: true
      end

      get "/specialists", SpecialistController, :index

      scope "/specialists", Specialists, as: :specialists do
        get "/:specialist_id/bio", BioController, :show
        get "/:specialist_id/prices", PricesController, :index
        get "/:specialist_id/insurance_providers", InsuranceProvidersController, :index
        get "/:specialist_id/location", LocationController, :show
      end

      get "/upload/file_upload_url", FileUploadController, :generate_signed_url
      post "/upload/file_upload_url/visit", FileUploadController, :upload_document_for_visit

      scope "/visits", Visits, as: :visits do
        get "/medical_category_calendar/:medical_category_id",
            MedicalCategoryCalendarController,
            :show

        post "/visit_demands/medical_category/:medical_category_id",
             VisitDemandsCategoryController,
             :create

        get "/visit_demands/medical_category/:medical_category_id",
            VisitDemandsCategoryController,
            :show

        post "/visit_demands/specialist/:specialist_id",
             VisitDemandsSpecialistController,
             :create

        get "/visit_demands/specialist/:specialist_id",
            VisitDemandsSpecialistController,
            :show

        get "/my_visits", VisitsController, :my_visits
        get "/show/:visit_id", VisitsController, :show

        get "/specialist_calendar/:specialist_id", SpecialistCalendarController, :show

        post "/specialist_calendar/:specialist_id/create_visit",
             SpecialistCalendarController,
             :create_visit

        post "/specialist_calendar/:specialist_id/create_us_board_visit",
             SpecialistCalendarController,
             :create_us_board_visit

        post "/:visit_id/move_to_canceled", VisitsController, :move_to_canceled

        get "/:record_id/uploaded_documents", VisitsController, :uploaded_documents

        get "/index_us_board_second_opinion", USBoardController, :index_us_board_second_opinion
        get "/us_board_second_opinion/:id", USBoardController, :us_board_second_opinion

        post "/request_us_board_second_opinion",
             USBoardController,
             :request_us_board_second_opinion

        get "/payment/:record_id", VisitsController, :payment_for_visit
      end

      put "/urgent_care", UrgentCareController, :cancel_call

      get "/notifications", NotificationController, :index
      get "/notifications/unread_count", NotificationController, :unread_count
      post "/notifications/mark_all_as_read", NotificationController, :mark_all_as_read
      post "/notifications/:id/mark_as_read", NotificationController, :mark_as_read
    end
  end
end
