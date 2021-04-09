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

  def run(argv) do
    parse_args(argv)
    |> read_tasks_text
    |> parse_tasks_text
    |> make_days_ast
    |> Enum.map(&TimeCalc.DailyTasks.make/1)
  end
end
