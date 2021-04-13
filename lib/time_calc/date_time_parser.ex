defmodule TimeCalc.DateTimeParser do
  @moduledoc """
  Models a parser for date and time components of tasks.
  """

  defmodule ParsedTime do
    @enforce_keys [:time]
    defstruct [:time, is_midnight: false]
  end

  def parse_date_text(date_text) do
    result = cond do
      String.length(date_text) == 6 ->
        [day_of_month_text, short_month] = String.split(date_text, "-")
        day_of_month = String.to_integer(day_of_month_text)
        month = case short_month do
          "Jan" -> 1
          "Feb" -> 2
          "Mar" -> 3
          "Apr" -> 4
          "May" -> 5
          "Jun" -> 6
          "Jul" -> 7
          "Aug" -> 8
          "Sep" -> 9
          "Oct" -> 10
          "Nov" -> 11
          "Dec" -> 12
          _ -> {:error, "Unrecognized short month, '#{short_month}'."}
        end
        case month do
          {:error, reason} -> {:error, reason}
          _ -> Date.new(NaiveDateTime.local_now().year, month, day_of_month)
        end
      true -> {:error, "Date must have exactly 6 characters but was '#{date_text}'"}
    end
    result
  end

  def parse_time_text(time_text) do
    result = cond do
      String.length(time_text) == 4 ->
        hour_text = String.slice(time_text, 0..1)
        candidate_hour = String.to_integer(hour_text)
        cond do
          0 <= candidate_hour and candidate_hour <= 24 ->
            is_midnight = if candidate_hour == 24 do
              true
            else
              false
            end
            hour = rem(candidate_hour, 24)
            minute_text = String.slice(time_text, 2..3)
            candidate_minute = String.to_integer(minute_text)
            cond do
              0 <= candidate_minute and candidate_minute <= 59 ->
                minute = candidate_minute
                %TimeCalc.DateTimeParser.ParsedTime{time: Time.new!(hour, minute, 0), is_midnight: is_midnight}
              true -> {:error, "Minute must be between 0 and 59, inclusive, but was '#{minute_text}'"}
            end
          true -> {:error, "Hour must be between 0 and 24, inclusive, but was '#{hour_text}'"}
        end
      true -> {:error, "Time must have exactly 4 digits but was '#{time_text}'"}
    end
    result
  end
end
