# DoraM - DORA Metrics

DoraM is a command-line tool that helps you track DevOps Research and Assessment (DORA) metrics from GitHub and Linear platforms.

## Installation

### Prerequisites

- Elixir 1.14 or later
- Erlang OTP 25 or later
- GitHub API token
- Linear API token

### Setup

1. Clone the repository:

```bash
git clone https://github.com/mighty-peach/dora_m.git
cd dora_m
```

2. Install dependencies:

```bash
mix deps.get
```

3. Create a configuration file:

Create or modify `config/config.exs` with your API keys:

```elixir
import Config

config :dora_m,
  gh_key: "your_github_token",
  gh_owner_repo: "owner/repository_name",
  linear_key: "your_linear_token",
  req_options: [] # keep it empty for tests

import_config "#{config_env()}.exs"
```

4. Build the executable:

```bash
mix escript.build
```

## Usage

DoraM provides various metrics from GitHub and Linear:

- `gh_avg_merged_hours`: Average time to merge GitHub PRs (in hours)
- `gh_amount_merged`: Number of merged GitHub PRs
- `linear_closed`: Number of closed Linear issues
- `linear_avg_bug_lifetime_hours`: Average lifetime of bugs in Linear (in hours)

### Basic Usage

```bash
# Run all available metrics for the last 7 days
./dora_m --modules all

# Run specific metrics for the last 14 days
./dora_m --modules gh_avg_merged_hours,linear_closed --period 14

# Display help
./dora_m --help
```

### Output Modes

DoraM supports multiple output formats:

```bash
# Default human-readable output
./dora_m --modules all

# Compact mode (better for copying to spreadsheets)
./dora_m --modules all --mode compact
```

### Example Output

#### Default mode:
```
Gh avg merged hours: 24
Gh amount merged: 15
Linear closed: 42
Linear avg bug lifetime hours: 36
```

#### Compact mode:
```
24
15
42
36
```

## Configuration Options

### GitHub Configuration

- `gh_key`: Your GitHub personal access token
- `gh_owner_repo`: The repository in the format "owner/repo_name"

### Linear Configuration

- `linear_key`: Your Linear API token

### Request Options

- `req_options`: Options for the HTTP client (empty list for production)

## Development

### Running Tests

```bash
mix test
```

The test configuration uses mock API responses for both GitHub and Linear APIs.

### Adding New Metrics

To add a new metric:

1. Add the metric name to the `@available_modules` list in `lib/dora_m/cli.ex`
2. Implement the metric calculation in the appropriate module (GitHub or Linear)
3. Update the `request/2` function in the respective module to include your new metric

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
