defmodule DoraM do
  @moduledoc """
  Run this program and get your release frequency and time to market
  """

  alias DoraM.{Github, Linear}

  def run_metrics(
        modules \\ [
          "gh_avg_merged_hours",
          "gh_amount_merged",
          "linear_closed",
          "linear_avg_bug_lifetime_hours"
        ],
        period \\ 7
      ) do
    github_modules = modules |> Enum.filter(&String.starts_with?(&1, "gh_"))
    linear_modules = modules |> Enum.filter(&String.starts_with?(&1, "linear_"))

    github_results =
      if !Enum.empty?(github_modules), do: Github.request(github_modules, period), else: []

    linear_results =
      if !Enum.empty?(linear_modules), do: Linear.request(linear_modules, period), else: []

    github_results ++ linear_results
  end
end
