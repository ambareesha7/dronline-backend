defmodule Authentication.TaskSupervisorMock do
  def start_child(_, fun), do: fun.()
end
