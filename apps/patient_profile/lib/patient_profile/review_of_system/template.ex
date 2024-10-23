defmodule PatientProfile.ReviewOfSystem.Template do
  def template do
    Proto.Forms.Form.new(
      fields: [
        Proto.Forms.FormField.new(
          uuid: "fdb32628-fc64-4e33-9595-374b28acdcc1",
          label: "General, Constitutional",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "c52d05a1-a990-4545-8976-01ba2cc52680",
                   label: "Recent weight loss"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "5558a11c-d252-4c45-9c1d-735a4e65f0b8",
                   label: "Fever"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "27b019b8-02bb-4595-91e4-4661cb70197c",
                   label: "Chills"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "8ce36167-6cc0-41f5-8586-3d3d1376e465",
          label: "Eyes, Vision",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "17118150-598e-4eaf-8ef5-65c63a231d49",
                   label: "Visual changes"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "dbdfd5dc-3278-44c1-8831-248b43f0ab0e",
          label: "Ears, Nose, Throat",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "22f309ac-b13c-4bba-9e44-e3b898266a53",
                   label: "Hearing loss"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "ca25f0c9-163d-4221-8350-ff2f490638e8",
          label: "Heart, Cardiovascular",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "37f167c3-cb5c-4f07-a67e-d87688aa0aee",
                   label: "Chest pain or pressure"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "0f2cc237-0def-4f03-beb3-ad7299c3212c",
                   label: "Arrythmia or palpitations"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "0e00af71-4145-4198-ab0f-df1bd196b0b6",
                   label: "Shortness of breath"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "05814eca-ce97-4ec9-b00e-76565590443f",
                   label: "Peripheral edema"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "1c035b3b-9e01-42c7-b7fb-dc4f2ab04eca",
                   label: "Blood clots"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "d2801cee-626f-43cb-bba6-15d116180959",
                   label: "Varicose veins"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "b3ccc33b-96ad-460d-bf23-32fe19486e3b",
                   label: "Cramping in thighs"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "e71b5deb-d16b-4e0a-9060-70815d2c50b2",
          label: "Respiratory",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "67507b57-9af7-44ef-9c7e-e3ce410e05e5",
                   label: "Cough"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "2d88ad85-3575-4dc4-bb70-a6b6cd6a9bf3",
                   label: "Shortness of breath"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "a766086d-bd1c-49ea-9774-6a9d00831461",
                   label: "Wheezing"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "ada1fd21-2db8-48d7-837b-52687b03ae2f",
          label: "Gastrointestinal",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "75ba636e-2f19-406b-ac0f-c6e8e6493d99",
                   label: "Abdominal pain"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "a77e0716-0e53-4c60-a315-e85d480b4e70",
                   label: "Heartburn"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "d0c69cbf-d9d5-404e-9600-b1001352950e",
                   label: "Bloody stool"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "06f24183-2547-40b4-aafd-cdec956db92e",
          label: "Genitourinary",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "aed175b5-a66d-4603-83ae-6c7f9945bf9f",
                   label: "Frequent urination"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "026cecba-26ff-4a7a-9460-16b7dfb12c9b",
                   label: "Urgency"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "3d392b99-c001-43f0-873f-e1f542e50768",
          label: "Musculoskeletal",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "35b6658a-8d36-4d37-b4ed-d79a9beca911",
                   label: "Joint pain or swelling"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "8be4a0e9-d61d-43b2-8a25-76a15cf6b6b5",
                   label: "Restricted motion"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "37e9e536-070b-4044-a189-c11a02b3b9ab",
                   label: "Musculoskeletal pain"
                 )
               ]
             )}
        ),
        Proto.Forms.FormField.new(
          uuid: "3ad2025e-aa14-47c2-a90e-7965ca085754",
          label: "Skin & Integumentary",
          value:
            {:multiselect,
             Proto.Forms.MultiSelect.new(
               options: [
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "ad65e610-829b-415e-bbcb-19ab79658f5d",
                   label: "Rashes"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "1277a5ed-b17b-4aab-ae44-f9c56da1b43b",
                   label: "Sores"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "127fcfcc-e2c1-4a77-91fa-e4937cd5634c",
                   label: "Blisters"
                 ),
                 Proto.Forms.MultiSelect.Option.new(
                   uuid: "82baf9d0-77dd-4e0c-819d-d96eb9edf1df",
                   label: "Growths"
                 )
               ]
             )}
        )
      ]
    )
  end
end
