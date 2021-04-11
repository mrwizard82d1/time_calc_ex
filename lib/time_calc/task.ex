defmodule TimeCalc.Task do
  @moduledoc """
  Models a task.
"""

  defstruct [:start, :end, :name]

  def duration(task), do: NaiveDateTime.diff(task.end, task.start)

end
