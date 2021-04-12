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

  test "parse date text when date valid" do
    year = NaiveDateTime.local_now().year
    assert TimeCalc.DailyTasks.parse_date_text("05-Apr") == {:ok, NaiveDateTime.new!(year, 4, 5, 0, 0, 0)}
    assert TimeCalc.DailyTasks.parse_date_text("01-Aug") == {:ok, NaiveDateTime.new!(year, 8, 1, 0, 0, 0)}
    assert TimeCalc.DailyTasks.parse_date_text("01-Dec") == {:ok, NaiveDateTime.new!(year, 12, 1, 0, 0, 0)}

    assert TimeCalc.DailyTasks.parse_date_text("28-Feb") == {:ok, NaiveDateTime.new!(year, 2, 28, 0, 0, 0)}
    assert TimeCalc.DailyTasks.parse_date_text("31-Jul") == {:ok, NaiveDateTime.new!(year, 7, 31, 0, 0, 0)}
    assert TimeCalc.DailyTasks.parse_date_text("31-Dec") == {:ok, NaiveDateTime.new!(year, 12, 31, 0, 0, 0)}
  end

    test "parse date text when date invalid" do
      year = NaiveDateTime.local_now().year
      assert TimeCalc.DailyTasks.parse_date_text("05-Mat") == {:error, "Unrecognized short month, 'Mat'."}
      assert TimeCalc.DailyTasks.parse_date_text("00-Aug") == NaiveDateTime.new(year, 8, 0, 0, 0, 0)
      assert TimeCalc.DailyTasks.parse_date_text("31-Mar") == NaiveDateTime.new(year, 3, 31, 0, 0, 0)
    end

end
