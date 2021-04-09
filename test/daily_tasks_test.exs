defmodule DailyTasksTest do
  use ExUnit.Case

  test "make_date when date valid" do
    assert TimeCalc.DailyTasks.make_date({"h1", [], ["05-Apr"], %{}}) ==
             NaiveDateTime.new!(NaiveDateTime.local_now().year, 4, 5, 0, 0, 0)
  end

  test "make_date fails when date invalid" do
    assert_raise MatchError, fn() -> TimeCalc.DailyTasks.make_date({"h1", [], ["17-Nob"], %{}}) end
    assert_raise MatchError, fn() -> TimeCalc.DailyTasks.make_date({"h1", [], ["31-Jun"], %{}}) end
    assert_raise MatchError, fn() -> TimeCalc.DailyTasks.make_date({"h1", [], ["3-Mar"], %{}}) end
  end

end
