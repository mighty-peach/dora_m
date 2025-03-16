defmodule DoraM.Linear do
  # schema URL: https://studio.apollographql.com/public/Linear-API/variant/current/explorer?explorerURLState=N4IgJg9gxgrgtgUwHYBcQC4QEcYIE4CeABAJIDOZuZAFACQBmAlgDYr7qkW4BiLbeAGiK0IeMPgBCBDgAUAhgHNGSOSkYQkAeTGSCASiLAAOkiJFGXBDSat2wm-yGjxeKRxE7X%2BwybNmADooIJEj0ED6mfmbIYADCMHhkor5RRAAWcmQAcggAHijyCggpURlkMngIAG7qMOVBJX5kKHJ4KPGJyZFmAL6NSBDiZBGpRFAQcP7MCGxgAIIojWZQlaoI84vdflBySFAI0xtLRK1QaYxV6wvHza2z11tmaijTjX2R7z0gAiBVrYxyABG0zIGBAxkiRhADnwUI4EKiUPGk2m90WGBGqShCjYcKIUIATAAGAkAVgAtESAMzkgCMRIAKrSqegiQAOdAAFk5ADoqWSAFpQt4pHoCFJQ5y6PFQmD%2BMBrI4gExfHpAA

  require Logger
  alias DoraM.Request

  @linear_key Application.compile_env!(:dora_m, :linear_key)
  @linear_api_url "https://api.linear.app/graphql"
  @query """
  query Issues($filter: IssueFilter, $orderBy: PaginationOrderBy, $first: Int, $after: String) {
    issues(filter: $filter, orderBy: $orderBy, first: $first, after: $after) {
      pageInfo {
        endCursor
        hasNextPage
        hasPreviousPage
        startCursor
      }
      nodes {
        completedAt
        createdAt
        canceledAt
        archivedAt
        startedAt
        title
        assignee {
          displayName
        }
        labels {
          nodes {
            name
          }
        }
      }
    }
  }
  """

  def request(modules \\ ["linear_closed", "linear_avg_bug_lifetime"], period_days \\ 7) do
    Logger.info("Linear: Receiving issues...")
    issues = make_request(period_days)
    Logger.info("Linear: issues received -> #{length(issues)}")

    modules
    |> Enum.map(fn module ->
      case module do
        "linear_closed" ->
          {:ok, module, length(issues)}

        "linear_avg_bug_lifetime" ->
          bugs =
            get_bugs(issues)

          lifetime =
            bugs
            |> Enum.map(&get_bug_lifetime(&1))
            |> Enum.sum()
            |> Kernel./(length(bugs))
            |> round()

          {:ok, module, lifetime}

        _ ->
          nil
      end
    end)
    |> Enum.filter(& &1)
  end

  defp make_request(period_days, issues \\ [], req_after \\ nil) do
    from_date =
      DateTime.utc_now() |> DateTime.shift(day: -1 * period_days) |> DateTime.to_iso8601()

    variables = get_variables(from_date, req_after)

    body =
      Jason.encode!(%{
        "query" => @query,
        "variables" => variables
      })

    task =
      Task.async(fn ->
        Request.post(
          @linear_api_url,
          [
            {"Authorization", @linear_key},
            {"Content-Type", "application/json"}
          ],
          body
        )
      end)

    case Task.await(task) do
      {:ok, response} ->
        issues = issues ++ response.body["data"]["issues"]["nodes"]
        has_next_page = response.body["data"]["issues"]["pageInfo"]["hasNextPage"]

        if has_next_page do
          cursor = response.body["data"]["issues"]["pageInfo"]["endCursor"]
          make_request(period_days, issues, cursor)
        else
          issues
        end

      {:error, error} ->
        Logger.error(inspect(error))
        []
    end
  end

  defp get_variables(from_date, req_after) do
    variables = %{
      "filter" => %{
        "completedAt" => %{
          "gte" => from_date
        }
      },
      "orderBy" => "updatedAt",
      "first" => 50
    }

    if not is_nil(req_after) do
      Map.put(variables, "after", req_after)
    else
      variables
    end
  end

  defp get_bugs(issues) do
    issues
    |> Enum.filter(
      &Enum.find(&1["labels"]["nodes"], fn label -> String.downcase(label["name"]) == "bug" end)
    )
  end

  defp get_bug_lifetime(bug) do
    {:ok, created_at, _} = DateTime.from_iso8601(bug["createdAt"])
    {:ok, completed_at, _} = DateTime.from_iso8601(bug["completedAt"])
    DateTime.diff(completed_at, created_at, :hour)
  end
end
