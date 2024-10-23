defmodule PatientProfile.HistoryForms.Templates do
  def default_social_form do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "c96fad63-633a-4f9f-b0fc-39f1c3867c79",
          label: "Marital Status",
          value: {
            :select,
            Proto.Forms.Select.new(
              options: [
                Proto.Forms.Select.Option.new(label: "Single"),
                Proto.Forms.Select.Option.new(label: "Married"),
                Proto.Forms.Select.Option.new(label: "Divorced"),
                Proto.Forms.Select.Option.new(label: "Widowed"),
                Proto.Forms.Select.Option.new(label: "Dependants")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "c6aba745-caa5-4d1a-af7c-4cb85433a3d8",
          label: "Occupation",
          value: {
            :select,
            Proto.Forms.Select.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.Select.Option.new(label: "None"),
                Proto.Forms.Select.Option.new(label: "Professional"),
                Proto.Forms.Select.Option.new(label: "Laborar"),
                Proto.Forms.Select.Option.new(label: "Driver")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "9cda303c-aa6e-49fa-b8b0-dc00fc061ddb",
          label: "Alcohol Consumption",
          value: {
            :select,
            Proto.Forms.Select.new(
              options: [
                Proto.Forms.Select.Option.new(label: "None"),
                Proto.Forms.Select.Option.new(label: "Social"),
                Proto.Forms.Select.Option.new(label: "Daily"),
                Proto.Forms.Select.Option.new(label: "Weekly")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "2fa930d4-008e-4d42-934a-3c468e91eb87",
          label: "Tobbaco Consumption",
          value: {
            :select,
            Proto.Forms.Select.new(
              options: [
                Proto.Forms.Select.Option.new(label: "None"),
                Proto.Forms.Select.Option.new(label: "Social"),
                Proto.Forms.Select.Option.new(
                  label: "Ciggars",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "c5d474b9-386d-404d-a999-d2a1a1d2c9d7",
                      label: "What Are You Smoking?",
                      value: {:string, Proto.Forms.StringField.new()}
                    ),
                    Proto.Forms.FormField.new(
                      uuid: "1de6d334-0527-4c7b-9963-395f3de1f2a0",
                      label: "Total Years Of Smoking",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    ),
                    Proto.Forms.FormField.new(
                      uuid: "37a078be-5f3d-4345-a9ca-6724af09f4b2",
                      label: "Packs per day",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    )
                  ]
                ),
                Proto.Forms.Select.Option.new(
                  label: "Stopped Smoking",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "dc0bc857-7fbc-465c-903e-03af7fa92fa6",
                      label: "What Had You Been Smoking?",
                      value: {:string, Proto.Forms.StringField.new()}
                    ),
                    Proto.Forms.FormField.new(
                      uuid: "05824d0d-e823-4b89-9cbc-f72703c1bf11",
                      label: "Approx. When Did You Stop?",
                      value: {:month, Proto.Forms.MonthField.new()}
                    ),
                    Proto.Forms.FormField.new(
                      uuid: "1d4e7df8-a48c-4aeb-a597-881e642d5101",
                      label: "Total Years Of Smoking",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    ),
                    Proto.Forms.FormField.new(
                      uuid: "2ed31c0f-0f1c-4608-92b6-01a9a3e49e6b",
                      label: "Packs per day",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "fbab7fab-c9bd-48f7-82a2-d5755ee4cc48",
          label: "Recreational Drugs",
          value: {
            :select,
            Proto.Forms.Select.new(
              options: [
                Proto.Forms.Select.Option.new(label: "None"),
                Proto.Forms.Select.Option.new(
                  label: "Yes",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "8d25fa9e-4705-4600-b188-c9f8a177cd97",
                      value: {
                        :multiselect,
                        Proto.Forms.MultiSelect.new(
                          options: [
                            Proto.Forms.MultiSelect.Option.new(label: "Amphetamines"),
                            Proto.Forms.MultiSelect.Option.new(label: "Cannabis"),
                            Proto.Forms.MultiSelect.Option.new(label: "MDMA"),
                            Proto.Forms.MultiSelect.Option.new(label: "Ketamine"),
                            Proto.Forms.MultiSelect.Option.new(label: "LSD"),
                            Proto.Forms.MultiSelect.Option.new(label: "Nitrous Oxide"),
                            Proto.Forms.MultiSelect.Option.new(label: "Opiates/opioids"),
                            Proto.Forms.MultiSelect.Option.new(label: "Psilocybin Mushrooms"),
                            Proto.Forms.MultiSelect.Option.new(label: "Research Chemicals")
                          ]
                        )
                      }
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "48a185d3-e388-4a4f-a80f-e1cc7e51c1d1",
          label: "Caffeinated Beverages",
          value: {
            :select,
            Proto.Forms.Select.new(
              options: [
                Proto.Forms.Select.Option.new(label: "None"),
                Proto.Forms.Select.Option.new(label: "Low"),
                Proto.Forms.Select.Option.new(label: "Moderate"),
                Proto.Forms.Select.Option.new(label: "Excessive")
              ]
            )
          }
        )
      ]
    )
  end

  def default_medical_form do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "dee0408d-b830-440e-b9ce-c5d33bf108a7",
          label: "Cardiovascular",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Aortic Aneurysm"),
                Proto.Forms.MultiSelect.Option.new(label: "High blood pressure"),
                Proto.Forms.MultiSelect.Option.new(label: "Cardiac valve disease"),
                Proto.Forms.MultiSelect.Option.new(label: "Anemia"),
                Proto.Forms.MultiSelect.Option.new(label: "Coronary artery disease"),
                Proto.Forms.MultiSelect.Option.new(label: "Atrial fibrillation"),
                Proto.Forms.MultiSelect.Option.new(label: "Congestive Heart Failure"),
                Proto.Forms.MultiSelect.Option.new(label: "Deap Vein Thrombosis"),
                Proto.Forms.MultiSelect.Option.new(label: "Heart Attack")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "f8a1a7fc-8535-45e8-b869-9d4588988a34",
          label: "Endocrine",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Diabites Mellitus"),
                Proto.Forms.MultiSelect.Option.new(label: "Goiter"),
                Proto.Forms.MultiSelect.Option.new(label: "Over active Thyroid"),
                Proto.Forms.MultiSelect.Option.new(label: "Under active Thyroid"),
                Proto.Forms.MultiSelect.Option.new(label: "Parathyroid")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "74abe17e-3986-40ce-aafa-0af45929bbf3",
          label: "Cancer",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Lung"),
                Proto.Forms.MultiSelect.Option.new(label: "Colon"),
                Proto.Forms.MultiSelect.Option.new(label: "Lymphoma"),
                Proto.Forms.MultiSelect.Option.new(label: "Leukemia"),
                Proto.Forms.MultiSelect.Option.new(label: "Bladder"),
                Proto.Forms.MultiSelect.Option.new(label: "Prostate (male)"),
                Proto.Forms.MultiSelect.Option.new(label: "Uterin (female)"),
                Proto.Forms.MultiSelect.Option.new(label: "Breast (female)")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "a68c390a-6a07-47c6-aa85-e5b4b8b2b087",
          label: "Gastro intestinal",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Gallstones"),
                Proto.Forms.MultiSelect.Option.new(label: "Colitis (type)"),
                Proto.Forms.MultiSelect.Option.new(label: "Crohn's"),
                Proto.Forms.MultiSelect.Option.new(label: "Diverticulitis"),
                Proto.Forms.MultiSelect.Option.new(label: "Reflux"),
                Proto.Forms.MultiSelect.Option.new(label: "Hiatal Hernia"),
                Proto.Forms.MultiSelect.Option.new(label: "Irritable Bowel"),
                Proto.Forms.MultiSelect.Option.new(label: "Peptic Ulcers"),
                Proto.Forms.MultiSelect.Option.new(label: "Pancreatitis"),
                Proto.Forms.MultiSelect.Option.new(label: "Hemorrhoids")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "469d2bac-1010-4f36-a19a-d71a6ae724ad",
          label: "General",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Allergies"),
                Proto.Forms.MultiSelect.Option.new(label: "Hepatitis A, B or C"),
                Proto.Forms.MultiSelect.Option.new(label: "Liver Disease"),
                Proto.Forms.MultiSelect.Option.new(label: "High Cholesterol"),
                Proto.Forms.MultiSelect.Option.new(label: "High Lipids"),
                Proto.Forms.MultiSelect.Option.new(label: "Obesity")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "818881a1-093a-4514-a82f-fd2f3eb3e7f2",
          label: "Heent",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Hearing loss"),
                Proto.Forms.MultiSelect.Option.new(label: "Glaucoma"),
                Proto.Forms.MultiSelect.Option.new(label: "Vertigo"),
                Proto.Forms.MultiSelect.Option.new(label: "Cataract")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "694c6693-ee1c-476d-9609-7000da507ec9",
          label: "Musculoskeletal",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Arthritis"),
                Proto.Forms.MultiSelect.Option.new(label: "Back Pain"),
                Proto.Forms.MultiSelect.Option.new(label: "Joint Pain"),
                Proto.Forms.MultiSelect.Option.new(label: "Carpal Tunnel Syndrom"),
                Proto.Forms.MultiSelect.Option.new(label: "Fibromyalgia")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "f349fe44-730c-480d-9a87-b01aa669a141",
          label: "Neuro/Psych",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "ADD"),
                Proto.Forms.MultiSelect.Option.new(label: "ADHD"),
                Proto.Forms.MultiSelect.Option.new(label: "Alcoholism"),
                Proto.Forms.MultiSelect.Option.new(label: "Anxiety"),
                Proto.Forms.MultiSelect.Option.new(label: "Depression"),
                Proto.Forms.MultiSelect.Option.new(label: "Stroke"),
                Proto.Forms.MultiSelect.Option.new(label: "Migraine"),
                Proto.Forms.MultiSelect.Option.new(label: "Seizures"),
                Proto.Forms.MultiSelect.Option.new(label: "Suicide Attempts")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "3d8929bd-c067-489b-9425-263ae6a16d31",
          label: "Respiratory",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Asthma"),
                Proto.Forms.MultiSelect.Option.new(label: "COPD/Emphysema"),
                Proto.Forms.MultiSelect.Option.new(label: "Pulmonary Embolism"),
                Proto.Forms.MultiSelect.Option.new(label: "Sleep Apnea")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "ef456e83-cfd6-4745-ab84-681dfb56415d",
          label: "GYN/OB/Breast",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Endometriosis"),
                Proto.Forms.MultiSelect.Option.new(label: "Fibrocystic Breast"),
                Proto.Forms.MultiSelect.Option.new(label: "Osteoporosis"),
                Proto.Forms.MultiSelect.Option.new(label: "Uterine Fibroid")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "ba8977b8-0c5f-4e87-b58d-cb6219422bad",
          label: "GU",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Kidney stones"),
                Proto.Forms.MultiSelect.Option.new(label: "Bladder Infections"),
                Proto.Forms.MultiSelect.Option.new(label: "Chronic Kidney Disease"),
                Proto.Forms.MultiSelect.Option.new(label: "Impotence"),
                Proto.Forms.MultiSelect.Option.new(label: "Difficulty urinating")
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "645fe937-e071-4607-89a6-567b8cde9dce",
          label: "Immunologic",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "AIDS/HIV"),
                Proto.Forms.MultiSelect.Option.new(label: "Lupus"),
                Proto.Forms.MultiSelect.Option.new(label: "MS")
              ]
            )
          }
        )
      ]
    )
  end

  def default_surgical_form do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "80eb4490-9a52-48c7-a6ce-ca01fcff9d5c",
          label: "Cardiovascular",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Angioplasty",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "dd5af704-0566-4aec-940c-b77375db7324",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Aortic Aneurysm",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "bd658254-627e-4a3b-bfa9-57b383aabb79",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Cardiac Stent",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "f2bd45d4-849d-4489-aafe-8337b610527a",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Cardiac Bypass",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "7d2dacda-84cc-4f1f-ba80-85afafd83afb",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Pacemacker/AICD",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "5c3e5aae-46a1-414e-b53c-2482121cf1b1",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "5a3fa30d-2011-442d-b7e7-307c3ace49e2",
          label: "General",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Brain surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "330ab6d3-c9fa-4b9d-b8dc-f0b09897f839",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Breast implant",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "6b71a4e9-c577-4aa1-9618-d8711834d8c4",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Breast surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "0a34e27f-ffd8-4bfb-9c25-703d56e3b092",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Hernia",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "41ee5933-0cef-4103-910c-c10e4214d072",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    ),
                    Proto.Forms.FormField.new(
                      uuid: "236dc91f-ba90-4017-97e3-04bbe6f023db",
                      value:
                        {:select,
                         Proto.Forms.Select.new(
                           options: [
                             Proto.Forms.Select.Option.new(label: "Umbilical"),
                             Proto.Forms.Select.Option.new(label: "Groin"),
                             Proto.Forms.Select.Option.new(label: "Incisional"),
                             Proto.Forms.Select.Option.new(label: "Hiatal")
                           ]
                         )}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Tummy Tuck",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "c55e2c24-bf50-4d68-8718-3e587902869d",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "1627b190-3960-4e8f-a86f-65df463be7e4",
          label: "GI",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Appendix",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "50e507f5-baf9-43d7-b7ee-7bad04e04ae5",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Bariatric (type)",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "4b20db92-124f-4a0c-be6a-417adaed6edf",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Small Bowel Resection",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "0d416d2b-319e-4395-9290-17fb6cd0bdf6",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Gallbladder",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "060661e0-c34e-4f94-b083-99b56fecf57d",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Colon Resection",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "31ff903a-5558-477f-ae51-85dc07267afc",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Colostomy",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "3c305625-dc34-41f6-9f0f-fca569148da5",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Esophagus",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "ce209ac6-2754-4f12-a22c-d557a7405052",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Anti reflux procedure",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "c336fcb4-f137-41a5-a155-f0879b279583",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Liver Surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "16a6c62d-309c-495b-9595-66bd93f690d0",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Stomach Surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "1aca247e-0688-498a-b7ef-9d9142a07bc6",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "3017e294-5086-4305-b9b2-51b362190930",
          label: "GU",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Bladder Surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "9c3a3a67-7583-43f5-bde4-fea87ba4222c",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Prostate",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "2378b3b0-4574-42fb-b27b-34e0f3fb7545",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Kidney Surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "d80582ad-1c10-42b2-97b3-47f2f46824a1",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Vasectomy",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "837a3015-3539-485b-a1c8-7c242613b5ab",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "c4954c5f-3b91-40e3-bf89-dd3e5295c49c",
          label: "GYN",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Ovarian cyst",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "c4897e90-286b-4e71-9f3f-322b54bd7d51",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "C-Section",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "88de027b-a790-4f06-a7aa-c2bc1c62d395",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Hysterectomy",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "c35b07dc-4196-4abf-bfeb-5ff46b470787",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Tubal Ligation",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "2ec78ba4-5d44-4616-acc9-4f1a447671a2",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "20b1f111-e68e-4126-8812-dbdf0997678c",
          label: "Heent",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Ear Surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "faf2c10b-8eba-4619-ab48-72d088b21415",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Eye Surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "886bfb10-6d16-4d79-ae91-57e9541142e9",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Nasal Surgery",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "97cbc3be-0cb2-463a-b327-cb419d1ee51d",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Thyroid",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "718e090c-a709-49be-8848-1ab4883a038e",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Parathyroid",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "8a128690-a263-4bf5-a38e-75c3507e75fa",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Tonsils",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "1931b749-7caa-4797-93e3-4348f4ea8acf",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                )
              ]
            )
          }
        ),
        Proto.Forms.FormField.new(
          uuid: "b24aaf50-7a37-4e6e-9d1e-4ed3cbfb4a4f",
          label: "Musculoskletal",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Spine",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "ea24280f-86c7-40ae-b2cc-09a7ebd54d09",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Hip",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "ebcfa3c6-85fa-4209-9a7c-3d305f1af34a",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Knee",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "4997d3a9-4f05-4682-ad9e-869a62363ad1",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Shoulder",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "526bc0bd-6fad-4b97-8c48-e91480741475",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Foot",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "1db22597-3f26-4dfa-abc3-c5fc7d3ff2c6",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Ankle",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "16879b8f-720b-4e08-87ea-29ffd8f2396f",
                      label: "When it was",
                      value: {:month, Proto.Forms.MonthField.new()}
                    )
                  ]
                )
              ]
            )
          }
        )
      ]
    )
  end

  def default_family_form do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "322fd440-814c-4186-b7c3-055f692c741d",
          label: "Family Diseases",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Anesthesia problems",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "ff69567e-714d-404f-a884-641289bef653",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Bleeding disorders",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "8177040d-f96d-471f-8328-cf0c691732d5",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Diabetes",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "4ed04c88-06f7-469c-9b81-a381a03914f8",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Stroke",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "28a50ab5-3063-4920-a5a0-71d78dd4ae06",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Heart Disease",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "6649ec16-ca26-48a0-96f3-83f359eba750",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Kidney Disease",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "e631c692-dc14-4bf6-bd78-a42e4e116802",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Crohn's Disease",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "b2bb6fe4-338b-4d2c-b1cb-5092fcc4bd72",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Systematic Lupus",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "4b56bebf-71e4-438f-8cd6-8ec31728abce",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Cancer (type)",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "60023931-6a0f-48b4-af79-dbd819be8e8f",
                      label: "Relationship To You",
                      value: {:string, Proto.Forms.StringField.new()}
                    )
                  ]
                )
              ]
            )
          }
        )
      ]
    )
  end

  def default_allergy_form do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "f0f899b4-d97e-4ced-bf31-dc43e3f54b14",
          label: "Allergies",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              allow_custom_option: true,
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(label: "Latex"),
                Proto.Forms.MultiSelect.Option.new(label: "Sulfa"),
                Proto.Forms.MultiSelect.Option.new(label: "Penicillin"),
                Proto.Forms.MultiSelect.Option.new(label: "Codeine")
              ]
            )
          }
        )
      ]
    )
  end

  def default_immunization_form do
    Proto.Forms.Form.new(
      completed: false,
      fields: [
        Proto.Forms.FormField.new(
          uuid: "2c24fcac-4ca9-4600-ac5e-3082c8f1b8d9",
          label: "Immunization",
          value: {
            :multiselect,
            Proto.Forms.MultiSelect.new(
              options: [
                Proto.Forms.MultiSelect.Option.new(label: "None", distinct: true),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Inactivated Polio (IPV)",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "4e71a6dc-c7c2-47ac-a71e-285d01d51b9b",
                      label: "At what age?",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Hepatisis B (HepB)",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "e0377f89-2b76-42fd-8f91-a0d3fd3818df",
                      label: "At what age?",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Rotavirus (RV)",
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "e0df99a9-6e36-4fe3-a5a7-636b2b2b9d57",
                      label: "At what age?",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Diptheria, tetanus, pertusis (DTaP)",
                  sublabels: ["Influenza virus (Hib)", "Pneumococcal (PCV13)"],
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "0a6a76fc-0358-428e-8a52-1ac230ba6abc",
                      label: "At what age?",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    )
                  ]
                ),
                Proto.Forms.MultiSelect.Option.new(
                  label: "Measeles, mumps & rubella (MMR)",
                  sublabels: [
                    "Varicella virus",
                    "Meningitis (MCV4)",
                    "Hepatitis A (HepA)",
                    "Tetanus"
                  ],
                  subform: [
                    Proto.Forms.FormField.new(
                      uuid: "525a5dd0-e408-4be4-a238-ae0a2e598c3e",
                      label: "At what age?",
                      value: {:integer, Proto.Forms.IntegerField.new()}
                    )
                  ]
                )
              ]
            )
          }
        )
      ]
    )
  end
end
