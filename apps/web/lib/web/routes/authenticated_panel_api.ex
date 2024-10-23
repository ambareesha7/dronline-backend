defmodule Web.Routes.AuthenticatedPanelApi do
  defmacro routes do
    quote do
      post "/change_password", AuthController, :change_password

      get "/channels_token", ChannelsTokenController, :show

      scope "/calls", Calls, as: :calls do
        get "/doctor_category_invitations/:category_id",
            QueueController,
            :doctor_category_invitations

        post "/nurse_patient_calls", PatientCallController, :create
        post "/specialist_patient_calls", PatientCallController, :create_for_specialist
        get "/patients_queue", QueueController, :patients_queue
        get "/patients_queue_v2", QueueController, :patients_queue_v2
        get "/pending_nurse_to_gp_calls", QueueController, :pending_nurse_to_gp_calls
        post "/pending_visit_call", VisitCallController, :pending_visit_call
        post "/doctor_pending_visit_call", VisitCallController, :doctor_pending_visit_call

        get "/:call_id/patient_location_coordinates",
            PatientLocationCoordinatesController,
            :show
      end

      post "/delete_account", AccountDeletionController, :delete_account

      put "/devices", DevicesController, :register
      put "/devices/unregister", DevicesController, :unregister

      put "/ios_devices", DevicesController, :register_ios
      put "/ios_devices/unregister", DevicesController, :unregister_ios

      scope "/dispatches" do
        get "/current_dispatches", DispatchesController, :current_dispatches
        get "/ended_dispatches", DispatchesController, :ended_dispatches
        get "/ongoing_dispatch", DispatchesController, :ongoing_dispatch
        get "/pending_dispatches", DispatchesController, :pending_dispatches

        post "/request_dispatch_to_patient", DispatchesController, :request_dispatch_to_patient

        get "/:request_id/details", DispatchesController, :details
        post "/:request_id/end_dispatch", DispatchesController, :end_dispatch
        post "/:request_id/take_pending_dispatch", DispatchesController, :take_pending_dispatch
      end

      scope "/emr", EMR, as: :emr do
        scope "/patients" do
          resources "/", PatientsController, only: [:create, :index]
          get "/connected", PatientsController, :index_connected
          post "/invite", InvitationsController, :create

          get "/connected_to_team_member/:specialist_id",
              PatientsController,
              :index_connected_to_team_member
        end

        scope "/medical_library" do
          get "/conditions", MedicalLibrariesController, :conditions
          get "/procedures", MedicalLibrariesController, :procedures
          get "/medications", MedicalLibrariesController, :medications
          get "/tests_by_categories", MedicalLibrariesController, :tests_by_categories
        end

        resources "/tests", TestsController, only: [:index]
        resources "/medications", MedicationsController, only: [:index]
        resources "/procedures", ProceduresController, only: [:index]

        scope "/patients/:patient_id" do
          resources "/records", RecordsController, only: [:create, :index, :show]
          post "/records/:id/close", RecordsController, :close

          scope "/records/:record_id" do
            resources "/hpi", HPIController,
              only: [:show, :update],
              singleton: true

            get "/hpi/history",
                HPIController,
                :history

            get "/ordered_tests/history",
                OrderedTestsController,
                :history_for_record

            get "/medications/history",
                MedicationsController,
                :history_for_record

            resources "/medical_summaries",
                      MedicalSummariesController,
                      only: [:create, :index]

            get "/medical_summaries/show_draft", MedicalSummariesController, :show_draft
            post "/medical_summaries/create_draft", MedicalSummariesController, :create_draft

            post "/medical_summaries/skip", MedicalSummariesController, :skip

            get "/medical_summaries/latest_for_specialist",
                MedicalSummariesController,
                :latest_for_specialist

            resources "/timeline_items/:timeline_item_id/comments",
                      CommentsController,
                      only: [:create, :index]

            post "/vitals", VitalsController, :create
            post "/ordered_tests", OrderedTestsController, :create
            post "/medications", MedicationsController, :create
          end

          get "/vitals", VitalsController, :show
          get "/vitals/history", VitalsController, :history
        end

        get "/pending_medical_summary", PendingMedicalSummariesController, :show, singleton: true

        get "/encounters/stats", EncountersController, :stats, singleton: true

        resources "/encounters",
                  EncountersController,
                  only: [:index, :show]
      end

      get "/medical_categories", MedicalCategoryController, :index

      scope "/membership", Membership, as: :membership do
        get "/", SubscriptionController, :show
        post "/cancel", SubscriptionController, :cancel
        get "/packages", PackagesController, :index
        get "/pending_subscription", SubscriptionController, :pending_subscription
        post "/subscribe", SubscriptionController, :subscribe
        post "/verify", SubscriptionController, :verify
      end

      get "/notifications", NotificationController, :index
      get "/notifications/unread_count", NotificationController, :unread_count
      post "/notifications/mark_all_as_read", NotificationController, :mark_all_as_read
      post "/notifications/:id/mark_as_read", NotificationController, :mark_as_read

      scope "/patients/:patient_id", Patients, as: :patients do
        resources "/address", AddressController, only: [:show, :update], singleton: true
        resources "/basic_info", BasicInfoController, only: [:show, :update], singleton: true
        resources "/bmi", BMIController, only: [:show, :update], singleton: true
        resources "/insurance", InsuranceController, only: [:show, :update], singleton: true

        resources "/history", HistoryFormsController, only: [:show, :update], singleton: true
        put "/history/all", HistoryFormsController, :update_all

        get "/relationship", RelationshipController, :show

        resources "/review_of_system", ReviewOfSystemController,
          only: [:show, :update],
          singleton: true

        get "/review_of_system/history", ReviewOfSystemController, :history
      end

      scope "/profile", Profile, as: :profile do
        resources "/basic_info", BasicInfoController, only: [:show, :update], singleton: true
        resources "/bio", BioController, only: [:show, :update], singleton: true
        resources "/credentials", CredentialsController, only: [:show], singleton: true
        resources "/location", LocationController, only: [:show, :update], singleton: true
        get "/prices", PricesController, :index
        resources "/prices", PricesController, only: [:update], singleton: true

        resources "/medical_credentials", MedicalCredentialsController,
          only: [:show, :update],
          singleton: true

        resources "/medical_categories", MedicalCategoriesController,
          only: [:show, :update],
          singleton: true

        put "/medical_info", MedicalInfoController, :update
        get "/status", StatusController, :show

        scope "/v2", V2, as: :v2 do
          resources "/basic_info", BasicInfoController, only: [:show, :update], singleton: true
          resources "/description", DescriptionController, only: [:show, :update], singleton: true
          resources "/education", EducationController, only: [:show, :update], singleton: true

          resources "/work_experience", WorkExperienceController,
            only: [:show, :update],
            singleton: true

          resources "/medical_info", MedicalInfoController,
            only: [:show, :update],
            singleton: true

          resources "/insurance_providers", InsuranceProvidersController,
            only: [:show, :update],
            singleton: true
        end
      end

      scope "/specialists" do
        get "/", SpecialistsController, :index
        get "/online", SpecialistsController, :index_online
        get "/category/:category_id", SpecialistsController, :category
      end

      scope "/visits", Visits, as: :visits do
        get "/my_calendar", SpecialistCalendarController, :my_calendar
        post "/my_calendar/create_timeslots", SpecialistCalendarController, :create_timeslots
        delete "/my_calendar/remove_timeslots", SpecialistCalendarController, :remove_timeslots

        post "/specialist_calendar/:specialist_id/create_timeslots",
             SpecialistCalendarController,
             :create_timeslots

        delete "/specialist_calendar/:specialist_id/remove_timeslots",
               SpecialistCalendarController,
               :remove_timeslots

        get "/ended", VisitController, :ended
        get "/pending", VisitController, :pending
        get "/pending_for_specialist", VisitController, :pending_for_specialist

        post "/:visit_id/move_to_canceled", VisitController, :move_to_canceled

        # Deprecated - use :pending_for_specialist instead
        get "/prepared", VisitController, :pending_for_specialist
        get "/upcoming", VisitController, :pending_for_specialist

        get "/:visit_id", VisitController, :show

        get "/:record_id/uploaded_documents", VisitController, :uploaded_documents

        get "/payment/:record_id", VisitController, :payment_for_visit
      end

      resources "/timelines", TimelineController, only: [:show]

      scope "/upload" do
        get "/profile_image_url", UploadController, :profile_image_url
      end

      scope "/team_invitations" do
        get "/", TeamController, :invitations
        put "/:team_id/accept", TeamController, :accept_invitation
        put "/:team_id/decline", TeamController, :decline_invitation
      end

      scope "/my_team" do
        get "/", TeamController, :show
        post "/", TeamController, :create_team

        get "/members", TeamController, :members
        put "/members/:specialist_id/role", TeamController, :set_role
        delete "/members/:specialist_id", TeamController, :delete_member
        post "/members/", TeamController, :add_member

        put "/location", TeamController, :set_location
        put "/branding", TeamController, :set_branding

        get "/stats", TeamController, :stats
        get "/urgent_care_stats", TeamController, :urgent_care_stats
      end

      scope "/payouts", Payouts, as: :payouts do
        resources "/credentials", CredentialsController, only: [:show, :update], singleton: true

        get "/withdrawals_summary", WithdrawalsSummaryController, :show
        get "/pending_withdrawals", PendingWithdrawalsController, :index
      end

      resources "/us_board_2nd_opinion", UsBoardSecondOpinionController,
        only: [:index, :show, :update]

      get "/us_board_2nd_opinion/by_visit_id/:visit_id",
          UsBoardSecondOpinionController,
          :by_visit_id

      post "/us_board_2nd_opinion/:request_id/accept", UsBoardSecondOpinionController, :accept
      post "/us_board_2nd_opinion/:request_id/reject", UsBoardSecondOpinionController, :reject

      put "/us_board_2nd_opinion/:request_id/submit_opinion",
          UsBoardSecondOpinionController,
          :submit_opinion
    end
  end
end
