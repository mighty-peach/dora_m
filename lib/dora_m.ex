defmodule DoraM do
  @moduledoc """
  Run this programm and get your release frequency and time to market
  """

  alias DoraM.Github

  def hello do
    Github.get_latest_merged_pull_requests()
  end
end
