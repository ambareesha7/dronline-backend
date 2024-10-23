defmodule Authentication do
  defdelegate authenticate_admin(auth_token),
    to: Authentication.Admin,
    as: :fetch_by_auth_token

  defdelegate authenticate_specialist(auth_token),
    to: Authentication.Specialist,
    as: :fetch_by_auth_token

  defdelegate authenticate_patient(auth_token),
    to: Authentication.Patient.AuthTokenEntry,
    as: :fetch_patient_id_by_auth_token

  defdelegate confirm_password_change(confirmation_token),
    to: Authentication.Specialist.PasswordChange.Confirm,
    as: :call

  defdelegate create_password_change(specialist_id, password),
    to: Authentication.Specialist.PasswordChange.Create,
    as: :call

  defdelegate fetch_specialist_by_id(specialist_id),
    to: Authentication.Specialist,
    as: :fetch_by_id

  defdelegate fetch_specialists(specialist_ids),
    to: Authentication.Specialist,
    as: :fetch_by_ids

  defdelegate generate_auth_token_entry_for_patient(patient_id),
    to: Authentication.Patient.AuthTokenEntry,
    as: :create

  defdelegate get_auth_token_entries(patient_ids),
    to: Authentication.Patient.AuthTokenEntry,
    as: :get_by_patient_ids

  defdelegate get_patient_account_by_phone_number(phone_number),
    to: Authentication.Patient.Account,
    as: :get_by_phone_number

  defdelegate fetch_patient_account_by_patient_ids(ids),
    to: Authentication.Patient.Account,
    as: :fetch_all_by_main_patient_ids

  defdelegate login_admin(email, password),
    to: Authentication.Admin.Login,
    as: :call

  defdelegate login_specialist(email, password),
    to: Authentication.Specialist.Login,
    as: :call

  defdelegate login_patient(firebase_token),
    to: Authentication.Patient.Login,
    as: :call

  defdelegate recover_specialist_password(token, new_password),
    to: Authentication.Specialist.RecoverPassword,
    as: :call

  defdelegate send_specialist_password_recovery(email),
    to: Authentication.Specialist.SendPasswordRecovery,
    as: :call

  defdelegate signup_external(email, password),
    to: Authentication.Specialist.Signup,
    as: :call

  defdelegate verify_specialist(verification_token),
    to: Authentication.Specialist.Verify,
    as: :call

  defdelegate create_patient_account_without_signup(params),
    to: Authentication.Patient.CreateNoSignUpAccount,
    as: :call
end
