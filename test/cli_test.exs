defmodule CliTest do
  use ExUnit.Case

  test ":help returned when requested" do
    assert TimeCalc.Cli.parse_args(["-h"]) == :help
    assert TimeCalc.Cli.parse_args(["--help"]) == :help
  end

  test "returns supplied filename when filename supplied" do
    assert TimeCalc.Cli.parse_args(["foo_bar.txt"]) == "foo_bar.txt"
  end

  test ":help returned when too many / too few options supplied" do
    assert TimeCalc.Cli.parse_args(["first.arg", "second.arg"]) == :help
    assert TimeCalc.Cli.parse_args([]) == :help
  end
end
