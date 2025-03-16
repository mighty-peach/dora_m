defmodule DoraM.Github do
  require Logger
  alias DoraM.Request

  @gh_key Application.compile_env!(:dora_m, :gh_key)
  @gh_owner_repo Application.compile_env!(:dora_m, :gh_owner_repo)
  @per_page 100

  # processes different metrics which you can get from GitHub API
  def request(modules \\ [:gh_avg_merged, :gh_amount_merged], period_days \\ 7) do
    Logger.info("GitHub: Receiving pull requests...")

    task = Task.async(fn -> get_pull_requests_for_period(period_days) end)
    pull_requests = Task.await(task)

    Logger.info("GitHub: Pull requests received, #{length(pull_requests)}")

    modules
    |> Enum.map(fn module ->
      case module do
        :gh_avg_merged ->
          average = avg_merged(pull_requests)
          Logger.info("GitHub: Average pull request lifetime: #{average}")
          {:ok, module, average}

        :gh_amount_merged ->
          amount = amount_merged(pull_requests)
          Logger.info("GitHub: Amount of merged pull requests: #{amount}")
          {:ok, module, amount}

        _ ->
          nil
      end
    end)
    |> Enum.filter(& &1)
  end

  # returns a list of pull requests for a given period
  defp get_pull_requests_for_period(period_days) do
    datetime_period = DateTime.shift(DateTime.utc_now(), day: -1 * period_days)

    default_url =
      "https://api.github.com/repos/#{@gh_owner_repo}/pulls?per_page=#{@per_page}&state=all"

    get_all_pull_requests([], default_url, datetime_period)
  end

  # returns a list of pull requests for a given period, handles pagination
  defp get_all_pull_requests(pull_requests, url, period_days) do
    response = make_request(url)

    case response do
      {:ok, response} ->
        next_batch =
          response.body
          |> filter_pull_requests(period_days)

        requested_all? = length(next_batch) != @per_page
        next_url = get_next_page_url(response.headers)
        pull_requests = pull_requests ++ next_batch

        if not requested_all? and not is_nil(next_url) do
          get_all_pull_requests(pull_requests, next_url, period_days)
        else
          pull_requests
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp make_request(url) do
    Request.get(
      url,
      [
        {"Authorization", "Bearer #{@gh_key}"},
        {"X-GitHub-Api-Version", "2022-11-28"},
        {"Accept", "application/vnd.github.v3+json"}
      ]
    )
  end

  # filters closed pull requests and requests out of given period
  defp filter_pull_requests(pull_requests, datetime_period) do
    pull_requests
    |> Enum.filter(fn pull_request ->
      merged_at = pull_request["merged_at"]
      closed_at = pull_request["closed_at"]

      cond do
        merged_at == nil and closed_at != nil ->
          false

        merged_at == nil ->
          true

        true ->
          {:ok, merged_at, _} = DateTime.from_iso8601(merged_at)
          DateTime.compare(merged_at, datetime_period) == :gt
      end
    end)
  end

  # finds url of next page in headers
  # GitHub, how bad is pagination designed!
  defp get_next_page_url(headers) do
    if is_nil(Map.get(headers, "link")) do
      nil
    else
      link_header = Enum.at(headers["link"], 0)
      regex = ~r/<([^>]+)>;\s*rel="next"/

      case Regex.run(regex, link_header) do
        [_, next_url] ->
          next_url

        _ ->
          nil
      end
    end
  end

  # calculates average time to merge a PR in hours
  defp avg_merged(pull_requests) do
    merged_prs = Enum.filter(pull_requests, &(&1["merged_at"] != nil))

    if Enum.empty?(merged_prs) do
      # return 0 if no merged PRs in the period
      0
    else
      merged_prs
      |> Enum.map(fn pr ->
        {:ok, created_at, _} = DateTime.from_iso8601(pr["created_at"])
        {:ok, merged_at, _} = DateTime.from_iso8601(pr["merged_at"])

        ms = DateTime.diff(merged_at, created_at, :millisecond)
        ms / :timer.hours(1)
      end)
      |> Enum.sum()
      |> Kernel./(length(merged_prs))
      # rounded to nearest whole hour
      |> Kernel.round()
    end
  end

  defp amount_merged(pull_requests) do
    pull_requests
    |> Enum.filter(&(&1["merged_at"] != nil))
    |> Enum.count()
  end
end
