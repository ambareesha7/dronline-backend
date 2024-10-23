defmodule PushNotifications do
  defdelegate register_patient_ios_device(patient_id, device_token),
    to: PushNotifications.Devices.PatientIOSDevice,
    as: :register

  defdelegate register_specialist_ios_device(specialist_id, device_token),
    to: PushNotifications.Devices.SpecialistIOSDevice,
    as: :register

  defdelegate register_patient_device(patient_id, firebase_token),
    to: PushNotifications.Devices.PatientDevice,
    as: :register

  defdelegate register_specialist_device(specialist_id, firebase_token),
    to: PushNotifications.Devices.SpecialistDevice,
    as: :register

  defdelegate unregister_patient_ios_device(patient_id, device_token),
    to: PushNotifications.Devices.PatientIOSDevice,
    as: :unregister

  defdelegate unregister_specialist_ios_device(specialist_id, device_token),
    to: PushNotifications.Devices.SpecialistIOSDevice,
    as: :unregister

  defdelegate unregister_patient_device(patient_id, firebase_token),
    to: PushNotifications.Devices.PatientDevice,
    as: :unregister

  defdelegate unregister_specialist_device(specialist_id, firebase_token),
    to: PushNotifications.Devices.SpecialistDevice,
    as: :unregister
end
