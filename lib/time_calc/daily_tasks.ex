defmodule TimeCalc.DailyTasks do
  @moduledoc """
  Module for managing activities.
  """

  def make_date({"h1", [], [date_text], _}) do
    {:ok, partial_date} = Timex.parse(date_text, "{0D}-{Mshort}")
    %NaiveDateTime{partial_date | year: NaiveDateTime.local_now().year}
  end

  def make_start_time(start_time_of_day, task_date) do
    %NaiveDateTime{task_date | hour: start_time_of_day.hour, minute: start_time_of_day.minute}
  end

  def make_task_partial_pieces(date, task_line) do
    [start_text, details] = task_line
                            |> String.split("\s", parts: 2)
    {:ok, start_time_of_day }= Timex.parse(start_text, "{h24}{m}")
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
    make_tasks(date, task_asts)
  end

end
