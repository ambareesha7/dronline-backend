defmodule Mailers.Partials do
  @external_resource Path.expand("style.css", __DIR__)
  @css File.read!(Path.expand("style.css", __DIR__))

  defmacro __using__(_opts) do
    quote do
      require EEx

      @css unquote(@css)

      path = unquote(Path.expand("partials/_head.html.eex", __DIR__))
      EEx.function_from_file(:defp, :head_html, path, [:css])
      path = unquote(Path.expand("partials/_header.html.eex", __DIR__))
      EEx.function_from_file(:defp, :header_html, path, [:assigns])
      path = unquote(Path.expand("partials/_footer.html.eex", __DIR__))
      EEx.function_from_file(:defp, :footer_html, path, [])
      path = unquote(Path.expand("partials/_footer.text.eex", __DIR__))
      EEx.function_from_file(:defp, :footer_text, path, [])
    end
  end
end
