defmodule DoraMTest do
  use ExUnit.Case
  doctest DoraM

  test "greets the world" do
    assert DoraM.hello() == :world
  end
end
