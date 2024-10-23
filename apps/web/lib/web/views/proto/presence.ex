defmodule Web.Views.Presence do
  def render_presence_state(presence_list) do
    %Proto.Presence.PresenceState{
      presences: Enum.map(presence_list, &presence/1)
    }
  end

  def render_presence_diff(joins, leaves) do
    %Proto.Presence.PresenceDiff{
      joins: Enum.map(joins, &presence/1),
      leaves: Enum.map(leaves, &presence/1)
    }
  end

  defp presence({key, metadata}) do
    %Proto.Presence.Presence{id: key, metadata: Enum.map(metadata, &metadata/1)}
  end

  defp metadata(metadata) do
    %Proto.Presence.Metadata{
      phx_ref: metadata.phx_ref
    }
  end
end
