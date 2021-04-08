defmodule TimeCalcTest do
  use ExUnit.Case
  doctest TimeCalc

  test "greets the world" do
    assert TimeCalc.hello() == :world
  end
end
