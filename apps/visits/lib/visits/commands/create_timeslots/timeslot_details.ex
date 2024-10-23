defmodule Visits.Commands.CreateTimeslots.TimeslotDetails do
  @moduledoc """
  Module defining a structure for storing timeslot details which are its
  start_time as unix timestamp and visit_type.
  """

  @type t :: %__MODULE__{
          start_time: pos_integer,
          visit_type: atom
        }

  @fields [:start_time, :visit_type]

  @enforce_keys @fields
  defstruct @fields
end
