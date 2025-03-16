import Config

config :dora_m,
  gh_key: "gh_key",
  gh_owner_repo: "owner/repo",
  linear_key: "linear_key",
  req_options: [
    plug: {Req.Test, DoraM.Request}
  ]
