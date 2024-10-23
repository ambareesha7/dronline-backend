defmodule Web.Plugs.VerifySpecialistPatientConnection do
  @moduledoc """
  Plug verifies if logged external specialist has been in contact with patient
  in order to process a request.

  Params:
    - `param_name` used to get information about patient (required)
    - `via_timeline` (boolean) sets a type of given `param_name`. If `via_timeline`
      is set to `false` (default) value passed in param `param_name` is threated
      as `patient_id`, otherwise it is used as `timeline_id`.
  """
  use Web, :plug

  @impl Plug
  def init(opts) do
    param_name = Keyword.fetch!(opts, :param_name)
    via_timeline = Keyword.get(opts, :via_timeline, false)

    unless is_boolean(via_timeline),
      do: raise(ArgumentError, message: "via_timeline must be a boolean")

    %{param_name: param_name, via_timeline: via_timeline}
  end

  @impl Plug
  def call(%{assigns: %{scopes: ["EXTERNAL", _package]}} = conn, opts) do
    param_name = opts.param_name

    specialist_id = conn.assigns.current_specialist_id
    param_id = Map.fetch!(conn.params, param_name)

    if EMR.specialist_patient_connected?(specialist_id, param_id, opts.via_timeline) do
      conn
    else
      conn
      |> send_resp(403, "")
      |> halt()
    end
  end

  def call(conn, _opts), do: conn
end
