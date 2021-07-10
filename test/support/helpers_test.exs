defmodule Test.Support.HelpersTest do
  use ExUnit.Case, async: true

  alias Test.Support.Helpers

  describe "uuid" do
    test "generates a random uuid" do
      assert Helpers.uuid() =~ ~r/[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}/
    end
  end
end
