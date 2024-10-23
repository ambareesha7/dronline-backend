defmodule Mix.Tasks.Gen.Adr do
  @moduledoc """
  Generates new ADR file in docs/adr dir

  """
  @shortdoc "Generates new ADR file in docs/adr dir"

  use Mix.Task

  @adr_dir "docs/adr"
  @adr_template """
  # Add Title here

  ## Context

  Describe some context here

  ## Decision

  Decision [DATE]

  ## Reason

  Describe reason here

  ## Consequences

  Describe consequences here

  ## Alternatives

  Describe alternatives here

  """

  @impl Mix.Task
  def run(_args) do
    unless Mix.Project.umbrella?(), do: Mix.raise("gen.adr: should be run in umrella root")

    existing_files = File.ls!(@adr_dir)

    current_number =
      existing_files
      |> Enum.sort()
      |> List.last()
      |> String.slice(0..2)
      |> String.to_integer()

    formatted_next_number = :io_lib.format(~c"~3..0B", [current_number + 1])

    File.write!("#{@adr_dir}/#{formatted_next_number}.md", @adr_template)
  end
end
