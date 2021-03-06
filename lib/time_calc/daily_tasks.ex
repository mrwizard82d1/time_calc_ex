defmodule TimeCalc.DailyTasks do
  @moduledoc """
  Module for managing activities.
  """

  def make_date({"h1", [], [date_text], _}) do
    {:ok, partial_date} = TimeCalc.DateTimeParser.parse_date_text(date_text)
    %Date{partial_date | year: NaiveDateTime.local_now().year}
  end

  def make_start_time(start_time_of_day, task_date) do
    %NaiveDateTime{task_date | hour: start_time_of_day.hour, minute: start_time_of_day.minute}
  end

  def make_task_partial_pieces(date, task_line) do
    [start_text, details] = task_line
                            |> String.split("\s", parts: 2)
    {:ok, parsed_start_time_of_day} = TimeCalc.DateTimeParser.parse_time_text(start_text)
    start_time = case parsed_start_time_of_day do
      %TimeCalc.DateTimeParser.ParsedTime{time: start_time_of_day, is_midnight: false} ->
        NaiveDateTime.new!(date, start_time_of_day)
      %TimeCalc.DateTimeParser.ParsedTime{time: start_time_of_day, is_midnight: true} ->
        adjusted_date = Date.add(date, 1)
        NaiveDateTime.new!(adjusted_date, start_time_of_day)
    end
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
