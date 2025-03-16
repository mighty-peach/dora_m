defmodule DoraM.GithubTest do
  alias DoraM.Github
  use ExUnit.Case

  test "return average lifetime of merged pull requests" do
    # Arrange
    today = DateTime.utc_now()

    pull_requests = [
      %{
        "id" => 1,
        "created_at" => today |> DateTime.shift(day: -6) |> DateTime.to_iso8601(),
        "merged_at" => today |> DateTime.shift(day: -5) |> DateTime.to_iso8601(),
        "closed_at" => today |> DateTime.shift(day: -5) |> DateTime.to_iso8601()
      },
      %{
        "id" => 2,
        "created_at" => today |> DateTime.shift(day: -4) |> DateTime.to_iso8601(),
        "merged_at" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601(),
        "closed_at" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601()
      },
      %{
        "id" => 3,
        "created_at" => today |> DateTime.shift(day: -2) |> DateTime.to_iso8601(),
        "merged_at" => nil,
        "closed_at" => nil
      },
      %{
        "id" => 4,
        "created_at" => today |> DateTime.shift(day: -2) |> DateTime.to_iso8601(),
        "merged_at" => nil,
        "closed_at" => today |> DateTime.shift(day: -1) |> DateTime.to_iso8601()
      }
    ]

    Req.Test.stub(DoraM.Request, fn conn ->
      Req.Test.json(conn, pull_requests)
    end)

    # Act
    result = Github.request([:gh_avg_merged], 7)

    # Assert
    assert result == [{:ok, :gh_avg_merged, 24}]
  end

  test "return amount of merged pull requests" do
    # Arrange
    today = DateTime.utc_now()

    pull_requests = [
      %{
        "id" => 1,
        "created_at" => today |> DateTime.shift(day: -6) |> DateTime.to_iso8601(),
        "merged_at" => today |> DateTime.shift(day: -5) |> DateTime.to_iso8601(),
        "closed_at" => today |> DateTime.shift(day: -5) |> DateTime.to_iso8601()
      },
      %{
        "id" => 2,
        "created_at" => today |> DateTime.shift(day: -4) |> DateTime.to_iso8601(),
        "merged_at" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601(),
        "closed_at" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601()
      },
      %{
        "id" => 3,
        "created_at" => today |> DateTime.shift(day: -2) |> DateTime.to_iso8601(),
        "merged_at" => today |> DateTime.shift(day: -1) |> DateTime.to_iso8601(),
        "closed_at" => today |> DateTime.shift(day: -1) |> DateTime.to_iso8601()
      },
      %{
        "id" => 4,
        "created_at" => today |> DateTime.shift(day: -2) |> DateTime.to_iso8601(),
        "merged_at" => nil,
        "closed_at" => nil
      },
      %{
        "id" => 5,
        "created_at" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601(),
        "merged_at" => nil,
        "closed_at" => today |> DateTime.shift(day: -1) |> DateTime.to_iso8601()
      }
    ]

    Req.Test.stub(DoraM.Request, fn conn ->
      Req.Test.json(conn, pull_requests)
    end)

    # Act
    result = Github.request([:gh_amount_merged], 7)

    # Assert
    assert result == [{:ok, :gh_amount_merged, 3}]
  end
end
