defmodule DoraM do
  @moduledoc """
  Run this programm and get your release frequency and time to market
  """

  # TODO: cover with tests
  # TODO: add CLI like start
  # TODO: pass params to CLI

  alias DoraM.Github

  def hello do
    Github.request()
  end
end
