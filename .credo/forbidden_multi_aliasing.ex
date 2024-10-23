defmodule Credo.Check.Warning.ForbiddenMultiAliasing do
  @moduledoc """
  Don't use alias/import/require on multiple modules at the same time.

  Searching for the places where the A.Y module is used is not possible if it's written as
  A.{X, Y, Z}. It makes refactoring much harder.
  """

  @explanation [check: @moduledoc]

  use Credo.Check, base_priority: :high

  @doc false
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse(
         {fun, meta,
          [
            {
              {:., _, [{:__aliases__, _, namespaces}, :{}]},
              _,
              multialiases
            }
          ]} = ast,
         issues,
         issue_meta
       )
       when is_list(namespaces) and is_list(multialiases) and fun in [:alias, :import, :require] do
    {ast, issues_for_call(meta, issues, issue_meta, fun)}
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  def issues_for_call(meta, issues, issue_meta, fun) do
    [issue_for(issue_meta, meta[:line], fun) | issues]
  end

  defp issue_for(issue_meta, line_no, fun) do
    format_issue(
      issue_meta,
      message: "There should be no multi-module #{fun}",
      trigger: to_string(fun),
      line_no: line_no
    )
  end
end
