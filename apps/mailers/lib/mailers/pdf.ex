defmodule Mailers.PDF do
  # Disabled sobelow for this module
  # due to an issue with File.read
  # Traversal.FileModule: Directory Traversal in `File.read` - Low Confidence

  # sobelow_skip ["Traversal.FileModule"]

  @pdf_shell_params [
    "--disable-smart-shrinking",
    #  margin bottom 0
    "-B",
    "0",
    #  margin left 0
    "-L",
    "0",
    #  margin right 0
    "-R",
    "0",
    #  margin top 0
    "-T",
    "0"
  ]

  def from_html_to_base_64(html) do
    with {:ok, pdf_path} <-
           PdfGenerator.generate(html,
             delete_temporary: true,
             page_size: "A4",
             shell_params: @pdf_shell_params
           ),
         {:ok, content} <- File.read(pdf_path) do
      {:ok, Base.encode64(content)}
    else
      _ -> {:error, :pdf_generate}
    end
  end
end
