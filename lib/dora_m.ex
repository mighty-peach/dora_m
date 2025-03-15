defmodule DoraM do
  @moduledoc """
  Run this programm and get your release frequency and time to market
  """

  alias DoraM.Github

  def hello do
    Github.request()
  end
end
