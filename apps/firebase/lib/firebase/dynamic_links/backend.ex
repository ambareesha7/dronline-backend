defmodule Firebase.DynamicLinks.Backend do
  use Tesla, docs: false

  plug(Tesla.Middleware.BaseUrl, "https://firebasedynamiclinks.googleapis.com/v1")
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Logger)

  def generate(payload, options \\ []) do
    app_name = Keyword.get(options, :app_name, :patient)
    fallback_link = Keyword.get(options, :fallback_link, nil)

    android_package_name =
      case app_name do
        :specialist ->
          Application.get_env(:firebase, :specialist_android_package_name)

        :patient ->
          Application.get_env(:firebase, :patient_android_package_name)
      end

    ios_bundle_id =
      case app_name do
        :specialist ->
          Application.get_env(:firebase, :specialist_ios_bundle_id)

        :patient ->
          Application.get_env(:firebase, :patient_ios_bundle_id)
      end

    ios_appstore_id =
      case app_name do
        :specialist ->
          Application.get_env(:firebase, :specialist_ios_appstore_id)

        :patient ->
          Application.get_env(:firebase, :patient_ios_appstore_id)
      end

    path = "/shortLinks?key=#{Application.get_env(:firebase, :api_key)}"

    body =
      %{
        dynamicLinkInfo: %{
          dynamicLinkDomain: Application.get_env(:firebase, :dynamic_link_domain),
          link: link(payload),
          androidInfo: %{
            androidPackageName: android_package_name
          },
          iosInfo: %{
            iosBundleId: ios_bundle_id,
            iosAppStoreId: ios_appstore_id
          }
        },
        suffix: %{
          option: "SHORT"
        }
      }
      |> add_fallback_links(fallback_link)

    post(path, body)
  end

  defp link(payload) do
    landing_page_url()
    |> URI.parse()
    |> URI.merge(payload)
    |> to_string()
  end

  defp add_fallback_links(body, nil), do: body

  defp add_fallback_links(body, fallback_link) do
    body
    |> put_in([:dynamicLinkInfo, :androidInfo, :androidFallbackLink], fallback_link)
    |> put_in([:dynamicLinkInfo, :iosInfo, :iosFallbackLink], fallback_link)
  end

  defp landing_page_url, do: Application.get_env(:firebase, :landing_page_url)
end
