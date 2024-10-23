defmodule Credo.Check.Warning.ClipboardCopy do
  @moduledoc """
  Don't leave Clipboard.copy/1 or Clipboard.copy!/1 in code
  """

  @explanation [check: @moduledoc]

  use Credo.Check, base_priority: :high

  @doc false
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse(
         {{:., _, [{:__aliases__, _, [:Clipboard]}, fun]}, meta, _arguments} = ast,
         issues,
         issue_meta
       )
       when fun in [:copy, :copy!] do
    {ast, issues_for_call(meta, issues, issue_meta, fun)}
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  def issues_for_call(meta, issues, issue_meta, fun) do
    [issue_for(issue_meta, meta[:line], "Clipboard.#{fun}", fun) | issues]
  end

  defp issue_for(issue_meta, line_no, trigger, fun) do
    format_issue(
      issue_meta,
      message: "There should be no calls to Clipboard.#{fun}/1.",
      trigger: trigger,
      line_no: line_no
    )
  end
end
