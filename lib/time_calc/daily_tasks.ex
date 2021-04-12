defmodule TimeCalc.DailyTasks do
  @moduledoc """
  Module for managing activities.
  """

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
          _ -> NaiveDateTime.new(NaiveDateTime.local_now().year, month, day_of_month, 0, 0, 0)
        end
      true -> {:error, "Date must have exactly 6 characters but was '#{date_text}'"}
    end
    result
  end

  def make_date({"h1", [], [date_text], _}) do
    {:ok, partial_date} = parse_date_text(date_text)
    %NaiveDateTime{partial_date | year: NaiveDateTime.local_now().year}
  end

  def make_start_time(start_time_of_day, task_date) do
    %NaiveDateTime{task_date | hour: start_time_of_day.hour, minute: start_time_of_day.minute}
  end

  def parse_time_text(time_text) do
    result = cond do
      String.length(time_text) == 4 ->
        hour_text = String.slice(time_text, 0..1)
        candidate_hour = String.to_integer(hour_text)
        cond do
          0 <= candidate_hour and candidate_hour <= 24 ->
            hour = rem(candidate_hour, 24)
            day_of_month = cond do
              candidate_hour == 24 -> 2
              true -> 1
            end
            minute_text = String.slice(time_text, 2..3)
            candidate_minute = String.to_integer(minute_text)
            cond do
              0 <= candidate_minute and candidate_minute <= 59 ->
                minute = candidate_minute
                NaiveDateTime.new(0, 1, day_of_month, hour, minute, 0)
              true -> {:error, "Minute must be between 0 and 59, inclusive, but was '#{minute_text}'"}
            end
          true -> {:error, "Hour must be between 0 and 24, inclusive, but was '#{hour_text}'"}
        end
      true -> {:error, "Time must have exactly 4 digits but was '#{time_text}'"}
    end
    result
  end

  def make_task_partial_pieces(date, task_line) do
    [start_text, details] = task_line
                            |> String.split("\s", parts: 2)
    {:ok, start_time_of_day} = parse_time_text(start_text)
    start_time = %NaiveDateTime{date | hour: start_time_of_day.hour, minute: start_time_of_day.minute}
    [start_time, details]
  end

  def make_task({task_partial, end_time}) do
    [start_time, details | []] = task_partial
    %TimeCalc.Task{start: start_time, end: end_time, name: details}
  end

  def make_tasks(date, {"p", [], [tasks_text], _}) do
    task_partial_pieces = tasks_text
    |> String.split("\n")
    |> Enum.map(fn task_line -> make_task_partial_pieces(date, task_line) end)

    raw_end_times = task_partial_pieces
                    |> Enum.map(&List.first/1)
                    |> Enum.drop(1)
    duplicate_end_time = task_partial_pieces
                         |> List.last
                         |> List.first
    end_times = raw_end_times ++ [duplicate_end_time]
    Enum.map(Enum.zip(task_partial_pieces, end_times), &make_task/1)
  end

  def make([date_ast, task_asts]) do
    date = make_date(date_ast)
    %{date => make_tasks(date, task_asts)}
  end

  def merge_task_durations(_name, left_duration, right_duration) do
    left_duration + right_duration
  end

  def accumulate_task_duration(so_far, task) do
    Map.merge(so_far, task, &merge_task_durations/3)
  end

  def summarize_one_day({date, tasks}) do
    day_summary = tasks
                  |> Enum.map(fn task -> %{task.name => TimeCalc.Task.duration(task)} end)
                  |> Enum.reduce(%{}, &accumulate_task_duration/2)
    {date, day_summary}
  end

  def summarize(tasks), do: Enum.map(tasks, &summarize_one_day/1)

end
