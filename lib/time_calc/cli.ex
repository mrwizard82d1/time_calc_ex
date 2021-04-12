defmodule TimeCalc.Cli do
  @moduledoc """
  Execute the application after parsing the command line arguments used to invoke the application.
  """

  def parse_args(argv) do
    arguments = OptionParser.parse(argv, strict: [help: :boolean], aliases: [h: :help])
    case arguments do
      {[help: true], _, _} -> :help
      {_, [time_filename], _} -> time_filename
      _ -> :help
    end
  end

  def read_tasks_text(pathname), do: File.read!(pathname)

  def present_deprecation_messages(messages), do: IO.inspect(messages)

  def present_error_messages(messages), do: IO.inspect(messages)

  def parse_tasks_text(text) do
    case EarmarkParser.as_ast(text) do
      {:ok, ast, []} -> ast
      {:ok, ast, deprecation_messages} ->
        present_deprecation_messages deprecation_messages
        ast
      {:error, ast, error_messages} ->
        present_error_messages error_messages
        raise "Error parsing daily tasks"
    end
  end

  def make_days_ast(ast), do: Enum.chunk_every(ast, 2)

  def format_date_time(date) do
    {:ok, "2021-04-12 00:02:00.000000"}
  end

  def present_task_date(date) do
    case format_date_time(date) do
      {:ok, date_text} ->
        IO.puts "\n# #{date_text}\n"
      {:error, error} -> IO.inspect error
    end
  end

  def present_task_summary(task_summary) do
    case task_summary do
      {name, 0} -> nil
      {name, duration} ->
        :io.format("~16s: ~.2f~n", [name, duration / 3600])
    end
  end

  def present_tasks_summary(summary) do
    summary
    |> Enum.sort
    |> Enum.each(&present_task_summary/1)
  end

  def present_daily_summary({date, summary}) do
    present_task_date(date)
    present_tasks_summary(summary)
  end

  def run(argv) do
    parse_args(argv)
    |> read_tasks_text
    |> parse_tasks_text
    |> make_days_ast
    |> Enum.map(&TimeCalc.DailyTasks.make/1)
    |> Enum.map(&TimeCalc.DailyTasks.summarize/1)
    |> List.flatten
    |> Enum.each(&present_daily_summary/1)
  end
end
