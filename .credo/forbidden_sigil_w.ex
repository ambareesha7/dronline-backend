defmodule Credo.Check.Warning.ForbiddenSigilW do
  @moduledoc """
  Don't use sigil_w `~w()`

  Formatter leaves sigils as they are. This is especially annoying when you need to add
  new word in middle of very long list with alphabetical order.
  """

  @explanation [check: @moduledoc]

  use Credo.Check, base_priority: :high

  @doc false
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:sigil_w, meta, _} = ast, issues, issue_meta) do
    {ast, issues_for_call(meta, issues, issue_meta)}
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  def issues_for_call(meta, issues, issue_meta) do
    [issue_for(issue_meta, meta[:line]) | issues]
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message: "There should be no sigil_w",
      trigger: "~w",
      line_no: line_no
    )
  end
end
