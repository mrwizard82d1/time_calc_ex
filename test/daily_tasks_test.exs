defmodule DailyTasksTest do
  use ExUnit.Case

  test "make_date when date valid" do
    assert TimeCalc.DailyTasks.make_date({"h1", [], ["05-Apr"], nil}) ==
             NaiveDateTime.new!(NaiveDateTime.local_now().year, 4, 5, 0, 0, 0)
  end
end
