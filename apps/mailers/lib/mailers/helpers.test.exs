defmodule Mailers.HelpersTest do
  use ExUnit.Case, async: false
  alias Mailers.Helpers

  describe "format_specialist/3" do
    test "shows all the data when available" do
      assert "M.B.B.S John Helper" == Helpers.format_specialist("John", "Helper", "M_B_B_S")
    end

    test "doesn't show medical title when it's missing" do
      assert "John Helper" == Helpers.format_specialist("John", "Helper", nil)
    end

    test "doesn't show medical title when it's UNKNOWN_MEDICAL_TITLE" do
      assert "John Helper" == Helpers.format_specialist("John", "Helper", "UNKNOWN_MEDICAL_TITLE")
    end
  end
end
