defmodule Proto.Helpers do
  def ensure_loaded do
    {:ok, modules} = :application.get_key(:proto, :modules)
    Code.ensure_all_loaded(modules)
  end
end
