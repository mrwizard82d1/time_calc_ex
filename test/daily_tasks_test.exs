defmodule DailyTasksTest do
  use ExUnit.Case

  test "make_date when date valid" do
    assert TimeCalc.DailyTasks.make_date({"h1", [], ["05-Apr"], %{}}) ==
             Date.new!(NaiveDateTime.local_now().year, 4, 5)
  end

  test "make_date fails when date invalid" do
    assert_raise MatchError, fn() -> TimeCalc.DailyTasks.make_date({"h1", [], ["17-Nob"], %{}}) end
    assert_raise MatchError, fn() -> TimeCalc.DailyTasks.make_date({"h1", [], ["31-Jun"], %{}}) end
    assert_raise MatchError, fn() -> TimeCalc.DailyTasks.make_date({"h1", [], ["3-Mar"], %{}}) end
  end

  test "make_task_partial_pieces returns correct start time and details if valid input" do
    assert [NaiveDateTime.new!(2019, 7, 22, 5, 18, 00), "tempus"] ==
             TimeCalc.DailyTasks.make_task_partial_pieces(Date.new!(2019, 7, 22), "0518 tempus")
    assert [NaiveDateTime.new!(2023, 11, 15, 0, 0, 0), "tempus"] ==
             TimeCalc.DailyTasks.make_task_partial_pieces(Date.new!(2023, 11, 14), "2400 tempus")
  end
end
