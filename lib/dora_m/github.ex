defmodule DoraM.Github do
  @gh_key Application.compile_env!(:dora_m, :gh_key)
  @gh_owner_repo Application.compile_env!(:dora_m, :gh_owner_repo)
  @per_page 1

  # TODO: add pagination
  def get_latest_merged_pull_requests(period \\ 7 * 24) do
    response =
      Req.get(
        "https://api.github.com/repos/#{@gh_owner_repo}/pulls?per_page=#{@per_page}&state=closed",
        headers: [
          {"Authorization", "Bearer #{@gh_key}"},
          {"X-GitHub-Api-Version", "2022-11-28"},
          {"Accept", "application/vnd.github.v3+json"}
        ]
      )

    weekAgo = DateTime.shift(DateTime.utc_now(), hour: -1 * period)

    case response do
      {:ok, response} ->
        response =
          response.body
          |> Enum.filter(fn pull_request ->
            merged_at = pull_request["merged_at"]

            if merged_at == nil do
              false
            else
              {:ok, merged_at, _} = DateTime.from_iso8601(merged_at)
              DateTime.compare(merged_at, weekAgo) == :gt
            end
          end)

        length(response)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
