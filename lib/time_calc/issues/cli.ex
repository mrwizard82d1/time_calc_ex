defmodule TimeCalc.Cli do
  @moduledoc """
  Execute the application after parsing the command line arguments used to invoke the application.
  """

  def run(argv) do
    parse_args(argv)
  end

  def parse_args(argv) do
    arguments = OptionParser.parse(argv, strict: [help: :boolean], aliases: [h: :help])
    case arguments do
      {[help: true], _, _} -> :help
      {_, [time_filename], _} -> time_filename
      _ -> :help
    end
  end
end
