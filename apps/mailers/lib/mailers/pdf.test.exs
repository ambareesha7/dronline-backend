defmodule Mailers.PDFTest do
  alias Pbkdf2.Base64
  use ExUnit.Case, async: true

  @pdf_html """
  <html>
  <head><title>Test</title></head>
  <body>
    <h1>recipe</h1>
    <p>amount 420 AED</p>
  </body>
  </html>
  """

  describe "from_html_to_base_64/1" do
    test "generates base64 encoded string from html" do
      {:ok, base64_content} = Mailers.PDF.from_html_to_base_64(@pdf_html)

      assert is_binary(base64_content)
    end
  end
end
