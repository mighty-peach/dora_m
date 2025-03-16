defmodule DoraM.CLI do
  @moduledoc """
  Command-line interface for DoraM metrics.
  """

  require Logger
  alias DoraM.{Github, Linear}

  @available_modules [
    "gh_avg_merged",
    "gh_amount_merged",
    "linear_closed",
    "linear_avg_bug_lifetime"
  ]

  def main(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [
          modules: :string,
          period: :integer,
          help: :boolean,
          mode: :string
        ],
        aliases: [
          m: :modules,
          p: :period,
          h: :help,
          o: :mode
        ]
      )

    case opts do
      [help: true] ->
        display_help()

      _ ->
        process_options(opts)
    end
  end

  defp display_help do
    IO.puts("""
    DoraM - DORA Metrics - DevOps Research and Assessment Metrics

    Usage:
      dora_m --modules <modules> --period <days> [--mode <mode>]

    Options:
      --modules, -m    Comma-separated list of modules to run
                       (#{Enum.join(@available_modules, ", ")})
                       or 'all' to run all modules
      --period, -p     Period in days for metrics calculation (default: 7)
      --help, -h       Display this help message
      --mode, -o       Mode for metrics calculation (default: 'default')

    Examples:
      dora_m --modules gh_avg_merged,linear_closed --period 14
      dora_m --modules all
    """)
  end

  defp process_options(opts) do
    modules = parse_modules(Keyword.get(opts, :modules, "all"))
    period = Keyword.get(opts, :period, 7)
    mode = Keyword.get(opts, :mode, "default")

    Logger.info("Calculating metrics for the last #{period} days...")

    # Run Github metrics if needed
    github_modules = modules |> Enum.filter(&String.starts_with?(&1, "gh_"))
    linear_modules = modules |> Enum.filter(&String.starts_with?(&1, "linear_"))

    github_task = Task.async(fn -> Github.request(github_modules, period) end)
    linear_task = Task.async(fn -> Linear.request(linear_modules, period) end)

    github_results = Task.await(github_task)
    linear_results = Task.await(linear_task)

    results = github_results ++ linear_results

    display_results(results, mode)
  end

  defp parse_modules("all"), do: @available_modules

  defp parse_modules(modules_str) do
    modules_str
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim(&1))
    |> Enum.filter(fn module -> module in @available_modules end)
  end

  defp display_results(results, "compact") do
    values = results |> Enum.map(fn {:ok, _, value} -> "#{value}" end)
    IO.puts(Enum.join(values, "\n"))
  end

  defp display_results(results, _) do
    # Standard display format
    results
    |> Enum.each(fn {:ok, module, value} ->
      IO.puts("#{format_module_name(module)}: #{value}")
    end)
  end

  defp format_module_name(module) do
    module
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
