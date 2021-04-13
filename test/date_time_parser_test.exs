defmodule DateTimeParserTest do
  use ExUnit.Case

  test "parse date text when date valid" do
    year = NaiveDateTime.local_now().year
    assert TimeCalc.DateTimeParser.parse_date_text("05-Apr") == {:ok, Date.new!(year, 4, 5)}
    assert TimeCalc.DateTimeParser.parse_date_text("01-Aug") == {:ok, Date.new!(year, 8, 1)}
    assert TimeCalc.DateTimeParser.parse_date_text("01-Dec") == {:ok, Date.new!(year, 12, 1)}

    assert TimeCalc.DateTimeParser.parse_date_text("28-Feb") == {:ok, Date.new!(year, 2, 28)}
    assert TimeCalc.DateTimeParser.parse_date_text("31-Jul") == {:ok, Date.new!(year, 7, 31)}
    assert TimeCalc.DateTimeParser.parse_date_text("31-Dec") == {:ok, Date.new!(year, 12, 31)}
  end

  test "parse date text when date invalid" do
    year = NaiveDateTime.local_now().year
    assert TimeCalc.DateTimeParser.parse_date_text("05-Mat") == {:error, "Unrecognized short month, 'Mat'."}
    assert TimeCalc.DateTimeParser.parse_date_text("00-Aug") == Date.new(year, 8, 0)
    assert TimeCalc.DateTimeParser.parse_date_text("31-Mar") == Date.new(year, 3, 31)
  end

  test "parse time text when time valid" do
    assert TimeCalc.DateTimeParser.parse_time_text("0000") ==
             {:ok, %TimeCalc.DateTimeParser.ParsedTime{time: Time.new!(0, 0, 0)}}
    assert TimeCalc.DateTimeParser.parse_time_text("2217") ==
             {:ok, %TimeCalc.DateTimeParser.ParsedTime{time: Time.new!(22, 17, 0)}}
    assert TimeCalc.DateTimeParser.parse_time_text("0859") ==
             {:ok, %TimeCalc.DateTimeParser.ParsedTime{time: Time.new!(8, 59, 0)}}
    assert TimeCalc.DateTimeParser.parse_time_text("2400") ==
             {:ok, %TimeCalc.DateTimeParser.ParsedTime{time: Time.new!(0, 0, 0), is_midnight: true}}
  end

  test "parse time text when time invalid" do
    assert TimeCalc.DateTimeParser.parse_time_text("000") == {:error, "Time must have exactly 4 digits but was '000'"}
    assert TimeCalc.DateTimeParser.parse_time_text("01132") == {:error, "Time must have exactly 4 digits but was '01132'"}
    assert TimeCalc.DateTimeParser.parse_time_text("-124") ==
             {:error, "Hour must be between 0 and 24, inclusive, but was '-1'"}
    assert TimeCalc.DateTimeParser.parse_time_text("2503") ==
             {:error, "Hour must be between 0 and 24, inclusive, but was '25'"}
    assert TimeCalc.DateTimeParser.parse_time_text("03-1") ==
             {:error, "Minute must be between 0 and 59, inclusive, but was '-1'"}
    assert TimeCalc.DateTimeParser.parse_time_text("1760") ==
             {:error, "Minute must be between 0 and 59, inclusive, but was '60'"}
  end
end
