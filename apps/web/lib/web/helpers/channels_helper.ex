defmodule Web.ChannelsHelper do
  @doc """
  Parses result to channels handle_in/3 response format
  """
  def socket_response_for_result(result, socket) do
    case result do
      :ok ->
        {:reply, :ok, socket}

      {:error, reason} when is_binary(reason) ->
        {:reply, {:error, %{reason: reason}}, socket}

      {:error, reason} when is_atom(reason) ->
        {:reply, {:error, %{reason: Atom.to_string(reason)}}, socket}

      _ ->
        {:reply, :error, socket}
    end
  end
end
