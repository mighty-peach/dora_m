defmodule DoraM.LinearTest do
  alias DoraM.Linear
  use ExUnit.Case

  test "return number of closed issues" do
    # Arrange
    today = DateTime.utc_now()

    issues = [
      %{
        "completedAt" => today |> DateTime.shift(day: -5) |> DateTime.to_iso8601(),
        "createdAt" => today |> DateTime.shift(day: -6) |> DateTime.to_iso8601(),
        "canceledAt" => nil,
        "archivedAt" => nil,
        "startedAt" => today |> DateTime.shift(day: -6) |> DateTime.to_iso8601(),
        "title" => "Issue 1",
        "assignee" => %{"displayName" => "User 1"},
        "labels" => %{"nodes" => [%{"name" => "feature"}]}
      },
      %{
        "completedAt" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601(),
        "createdAt" => today |> DateTime.shift(day: -4) |> DateTime.to_iso8601(),
        "canceledAt" => nil,
        "archivedAt" => nil,
        "startedAt" => today |> DateTime.shift(day: -4) |> DateTime.to_iso8601(),
        "title" => "Issue 2",
        "assignee" => %{"displayName" => "User 2"},
        "labels" => %{"nodes" => [%{"name" => "enhancement"}]}
      },
      %{
        "completedAt" => today |> DateTime.shift(day: -1) |> DateTime.to_iso8601(),
        "createdAt" => today |> DateTime.shift(day: -2) |> DateTime.to_iso8601(),
        "canceledAt" => nil,
        "archivedAt" => nil,
        "startedAt" => today |> DateTime.shift(day: -2) |> DateTime.to_iso8601(),
        "title" => "Issue 3",
        "assignee" => %{"displayName" => "User 3"},
        "labels" => %{"nodes" => [%{"name" => "bug"}]}
      }
    ]

    Req.Test.stub(DoraM.Request, fn conn ->
      Req.Test.json(conn, %{
        "data" => %{"issues" => %{"nodes" => issues, "pageInfo" => %{"hasNextPage" => false}}}
      })
    end)

    # Act
    result = Linear.request([:linear_closed], 7)

    # Assert
    assert result == [{:ok, :linear_closed, 3}]
  end

  test "return average lifetime of bugs" do
    # Arrange
    today = DateTime.utc_now()

    issues = [
      %{
        "completedAt" => today |> DateTime.shift(day: -5) |> DateTime.to_iso8601(),
        "createdAt" => today |> DateTime.shift(day: -6) |> DateTime.to_iso8601(),
        "canceledAt" => nil,
        "archivedAt" => nil,
        "startedAt" => today |> DateTime.shift(day: -6) |> DateTime.to_iso8601(),
        "title" => "Bug 1",
        "assignee" => %{"displayName" => "User 1"},
        "labels" => %{"nodes" => [%{"name" => "bug"}]}
      },
      %{
        "completedAt" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601(),
        "createdAt" => today |> DateTime.shift(day: -6) |> DateTime.to_iso8601(),
        "canceledAt" => nil,
        "archivedAt" => nil,
        "startedAt" => today |> DateTime.shift(day: -5) |> DateTime.to_iso8601(),
        "title" => "Bug 2",
        "assignee" => %{"displayName" => "User 2"},
        "labels" => %{"nodes" => [%{"name" => "bug"}]}
      },
      %{
        "completedAt" => today |> DateTime.shift(day: -1) |> DateTime.to_iso8601(),
        "createdAt" => today |> DateTime.shift(day: -4) |> DateTime.to_iso8601(),
        "canceledAt" => nil,
        "archivedAt" => nil,
        "startedAt" => today |> DateTime.shift(day: -3) |> DateTime.to_iso8601(),
        "title" => "Feature",
        "assignee" => %{"displayName" => "User 3"},
        "labels" => %{"nodes" => [%{"name" => "feature"}]}
      }
    ]

    Req.Test.stub(DoraM.Request, fn conn ->
      Req.Test.json(conn, %{
        "data" => %{"issues" => %{"nodes" => issues, "pageInfo" => %{"hasNextPage" => false}}}
      })
    end)

    # Act
    result = Linear.request([:linear_avg_bug_lifetime], 7)

    # Assert
    assert result == [{:ok, :linear_avg_bug_lifetime, 48}]
  end
end
