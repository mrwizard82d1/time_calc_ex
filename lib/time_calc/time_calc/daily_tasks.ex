defmodule TimeCalc.DailyTasks do
  @moduledoc """
  Module for managing activities.
  """

  def make_date({"h1", [], [date_text], _}) do
    {:ok, partial_date} = Timex.parse(date_text, "{0D}-{Mshort}")
    %NaiveDateTime{partial_date | year: NaiveDateTime.local_now().year}
  end

  def make_tasks(date, {"p", [], [tasks_text], _}) do
    IO.inspect date
    IO.inspect tasks_text
  end

  def make([date_ast, task_asts]) do
    date = make_date(date_ast)
    tasks = make_tasks(date, task_asts)
  end

end
