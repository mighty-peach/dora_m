defmodule DoraM.Linear do
  # TODO: Closed issues per period
  # TODO: Average time before bag will be closed
  # TODO: Period everywhere to days
  # https://studio.apollographql.com/public/Linear-API/variant/current/explorer?explorerURLState=N4IgJg9gxgrgtgUwHYBcQC4QEcYIE4CeABAJIDOZuZAFACQBmAlgDYr7qkW4BiLbeAGiK0IeMPgBCBDgAUAhgHNGSOSkYQkAeTGSCASiLAAOkiJFGXBDSat2wm-yGjxeKRxE7X%2BwybNmADooIJEj0ED6mfmbIYADCMHhkor5RRAAWcmQAcggAHijyCggpURlkMngIAG7qMOVBJX5kKHJ4KPGJyZFmAL6NSBDiZBGpRFAQcP7MCGxgAIIojWZQlaoI84vdflBySFAI0xtLRK1QaYxV6wvHza2z11tmaijTjX2R7z0gAiBVrYxyABG0zIGBAxkiRhADnwUI4EKiUPGk2m90WGBGqShCjYcKIUIATAAGAkAVgAtESAMzkgCMRIAKrSqegiQAOdAAFk5ADoqWSAFpQt4pHoCFJQ5y6PFQmD%2BMBrI4gExfHpAA

  @linear_key Application.compile_env!(:dora_m, :linear_key)
  @linear_api_url "https://api.linear.app/graphql"

  defp make_request(period_days \\ 7) do
    from_date = Date.utc_today() |> Date.add(-1 * period_days) |> Date.to_iso8601()

    query = """
    query Issues($filter: IssueFilter, $orderBy: PaginationOrderBy) {
      issues(filter: $filter, orderBy: $orderBy) {
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
        }
      }
    }
    """

    variables = %{
      "filter" => %{
        "completedAt" => %{
          "gte" => from_date
        }
      },
      "orderBy" => "updatedAt"
    }

    Req.get(
      @linear_api_url,
      headers: [
        {"Authorization", @linear_key},
        {"Content-Type", "application/json"}
      ],
      json: %{
        "query" => query,
        "variables" => variables
      }
    )
  end
end
