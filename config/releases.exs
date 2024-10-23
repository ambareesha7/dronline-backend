import Config

config :emr,
  pdf_service_url: System.fetch_env!("PDF_SERVICE_URL"),
  tokbox_aws_bucket: System.fetch_env!("TOKBOX_AWS_BUCKET"),
  tokbox_id: System.fetch_env!("TOKBOX_API_KEY"),
  video_processing_temp_dir: System.fetch_env!("VIDEO_PROCESSING_TEMP_DIR")

config :ex_aws,
  access_key_id: System.fetch_env!("TOKBOX_AWS_KEY_ID"),
  region: System.fetch_env!("TOKBOX_AWS_REGION"),
  secret_access_key: System.fetch_env!("TOKBOX_AWS_SECRET")

config :firebase,
  api_key: System.fetch_env!("FIREBASE_API_KEY"),
  dynamic_link_domain: System.fetch_env!("FIREBASE_DYNAMIC_LINK_DOMAIN"),
  specialist_android_package_name: System.fetch_env!("FIREBASE_SPECIALIST_ANDROID_PACKAGE_NAME"),
  patient_android_package_name: System.fetch_env!("FIREBASE_PATIENT_ANDROID_PACKAGE_NAME"),
  specialist_ios_bundle_id: System.fetch_env!("FIREBASE_SPECIALIST_IOS_BUNDLE_ID"),
  patient_ios_bundle_id: System.fetch_env!("FIREBASE_PATIENT_IOS_BUNDLE_ID"),
  specialist_ios_appstore_id: System.fetch_env!("FIREBASE_SPECIALIST_IOS_APPSTORE_ID"),
  patient_ios_appstore_id: System.fetch_env!("FIREBASE_PATIENT_IOS_APPSTORE_ID"),
  landing_page_url: System.fetch_env!("LANDING_PAGE_URL"),
  project_name: System.fetch_env!("FIREBASE_PROJECT_NAME")

config :mailers, sparkpost_api_key: System.fetch_env!("SPARKPOST_API_KEY")
config :mailers, admin_email: System.fetch_env!("ADMIN_EMAIL_ADDRESS")
config :mailers, appunite_email: "ravin@dronline.ai"

config :membership,
  authkey: System.fetch_env!("TELR_AUTHKEY"),
  basic_auth_name: System.fetch_env!("TELR_BASIC_AUTH_NAME"),
  basic_auth_password: System.fetch_env!("TELR_BASIC_AUTH_PASSWORD"),
  gateway_url: System.fetch_env!("TELR_GATEWAY_URL"),
  store_id: System.fetch_env!("TELR_STORE_ID"),
  test_env: System.fetch_env!("TELR_TEST_ENV"),
  tools_url: System.fetch_env!("TELR_TOOLS_URL")

config :push_notifications,
  fcm_issuer: System.fetch_env!("FCM_ISSUER"),
  fcm_private_key: System.fetch_env!("FCM_PRIVATE_KEY"),
  fcm_url: System.fetch_env!("FCM_URL"),
  apns_key_id: System.fetch_env!("APNS_KEY_ID"),
  apns_private_key: System.fetch_env!("APNS_PRIVATE_KEY"),
  apns_team_id: System.fetch_env!("APNS_TEAM_ID"),
  apns_topic_url: System.fetch_env!("APNS_TOPIC_URL"),
  apns_url: System.fetch_env!("APNS_URL")

config :opentok,
  api_url: System.fetch_env!("TOKBOX_API_URL"),
  api_key: System.fetch_env!("TOKBOX_API_KEY"),
  secret: System.fetch_env!("TOKBOX_SECRET")

config :patient_profile,
  default_boy_avatar_path: System.fetch_env!("DEFAULT_BOY_AVATAR_PATH"),
  default_girl_avatar_path: System.fetch_env!("DEFAULT_GIRL_AVATAR_PATH"),
  default_man_avatar_path: System.fetch_env!("DEFAULT_MAN_AVATAR_PATH"),
  default_other_avatar_path: System.fetch_env!("DEFAULT_OTHER_AVATAR_PATH"),
  default_woman_avatar_path: System.fetch_env!("DEFAULT_WOMAN_AVATAR_PATH")

config :sentry,
  environment_name: System.fetch_env!("APP_ENV"),
  release: System.get_env("COMMIT_SHA"),
  dsn: System.fetch_env!("SENTRY_DSN")

config :twilio,
  account_sid: System.fetch_env!("TWILIO_ACCOUNT_SID"),
  key_sid: System.fetch_env!("TWILIO_KEY_SID"),
  key_secret: System.fetch_env!("TWILIO_KEY_SECRET"),
  messege_service_sid: System.fetch_env!("TWILIO_MESSAGE_SERVICE_SID")

config :upload,
  base_url: System.fetch_env!("GCS_BASE_URL"),
  bucket: System.fetch_env!("GCS_BUCKET"),
  private_key: System.fetch_env!("GCS_PRIVATE_KEY"),
  client_email: System.fetch_env!("GCS_CLIENT_EMAIL"),
  thumbor_url: System.fetch_env!("THUMBOR_URL")

config :visits, :telr,
  authkey: System.get_env("TELR_REMOTE_API_KEY"),
  payment_authkey: System.get_env("TELR_AUTHKEY"),
  store_id: System.get_env("TELR_STORE_ID"),
  test_env: System.get_env("TELR_TEST_ENV"),
  remote_api_url: System.get_env("TELR_REMOTE_API_URL"),
  hosted_payment_api_url: System.get_env("TELR_GATEWAY_URL")

config :web, Web.Endpoint,
  http: [port: System.fetch_env!("PORT")],
  url: [host: System.fetch_env!("HOST"), port: 443, scheme: "https"],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  load_from_system_env: true,
  server: true

config :teams_web, TeamsWeb.Endpoint,
  http: [port: {:system, "TEAMS_PORT"}],
  url: [host: {:system, "TEAMS_HOST"}, port: 443, scheme: "https"],
  secret_key_base: System.fetch_env!("TEAMS_SECRET_KEY_BASE"),
  load_from_system_env: true,
  server: true

config :web,
  specialist_panel_url: System.fetch_env!("SPECIALIST_PANEL_URL"),
  support_email: System.fetch_env!("SUPPORT_EMAIL"),
  whitelisted_domain: System.fetch_env!("WEB_DOMAINS")

config :urgent_care,
  default_clinic_id: System.fetch_env!("URGENT_CARE_DEFAULT_CLINIC_ID")
