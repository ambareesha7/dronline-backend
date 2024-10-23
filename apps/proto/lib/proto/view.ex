defmodule Proto.View do
  defmacro __using__(_opts) do
    quote do
      use Phoenix.View,
        root: "lib/proto/templates",
        namespace: Proto
    end
  end
end
