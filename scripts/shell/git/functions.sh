#!/usr/bin/env zsh
# Git-related Functions
# Functions for interacting with git repositories

# Lazy load guard
[[ -n "${_GIT_FUNCTIONS_LOADED}" ]] && return
_GIT_FUNCTIONS_LOADED=1

# Helper function to get organizations from saved repos
_get_local_orgs() {
  local base_dir="$HOME/GitHub"
  
  # Check if GitHub directory exists
  if [[ ! -d "$base_dir" ]]; then
    echo "No GitHub directory found at $base_dir"
    return 1
  fi
  
  # Find all organization directories (depth 1)
  find "$base_dir" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort
}

# Helper function to select organization interactively
_select_org() {
  local local_orgs
  local_orgs=$(_get_local_orgs)
  
  if [ -z "$local_orgs" ]; then
    echo "No local organizations found. Please clone a repository first with 'ghc <org>'."
    return 1
  fi
  
  echo "$local_orgs" | fzf --prompt="Select an organization > " --height="30%" --border
}

# Helper function to select repository interactively from GitHub API
_select_repo_from_github() {
  local org="$1"
  local repo_list
  local selected_repo
  local repo_name
  
  # --- Get Repository List ---
  echo "Fetching repositories for '$org'..." >&2
  repo_list=$(gh repo list "$org" --limit 1000) || return 1

  # Check if any repositories were found
  if [ -z "$repo_list" ]; then
      echo "No repositories found for organization '$org' or organization does not exist." >&2
      return 1
  fi

  # --- Interactive Selection with fzf ---
  selected_repo=$(echo "$repo_list" | fzf --prompt="Select a repository from '$org' > " --height="40%" --border)

  # Extract just the repository name (without org prefix)
  if [ -n "$selected_repo" ]; then
    repo_name=$(echo "$selected_repo" | awk '{print $1}')
    echo $(basename "$repo_name")
  fi
}

# ghrc (Git Repository Clone) - Interactively find and clone a repository from a GitHub
# organization into a structured directory (~/GitHub/<org>/<repo>).
# If no org is provided, shows a fuzzy finder to select from local orgs.
ghrc() {
  # --- 1. Handle Organization Selection ---
  local org
  if [ -z "$1" ]; then
    # No org provided, use fuzzy finder to select from local orgs
    org=$(_select_org)
    if [ -z "$org" ]; then
      echo "No organization selected."
      return 1
    fi
    echo "Selected organization: $org"
  else
    org="$1"
  fi

  # --- 2. Define Variables ---
  local base_dir="$HOME/GitHub"
  local org_dir="$base_dir/$org"
  local repo_list
  local selected_repo
  local repo_name
  local repo_basename

  # --- 3. Get Repository List ---
  # Use gh to list repos. If it fails, exit.
  # The '|| return 1' part stops the script if gh repo list fails.
  echo "Fetching repositories for '$org'..."
  repo_list=$(gh repo list "$org" --limit 1000) || return 1

  # Check if any repositories were found
  if [ -z "$repo_list" ]; then
      echo "No repositories found for organization '$org' or organization does not exist."
      return 1
  fi

  # --- 4. Calculate dynamic column widths ---
  # Get the maximum repository name length
  local max_repo_width
  max_repo_width=$(echo "$repo_list" | awk '{if (length($1) > max) max = length($1)} END {print max}')
  
  # Set minimum width of 20, add 2 for padding
  if [ "$max_repo_width" -lt 20 ]; then
    max_repo_width=20
  fi
  
  # Create header with dynamic width
  local repo_header=$(printf "%-${max_repo_width}s" "REPOSITORY")
  
  # --- 5. Interactive Selection with fzf and dynamic-width colors ---
  selected_repo=$(echo "$repo_list" | awk -v repo_width="$max_repo_width" '{
    repo_name = $1;
    visibility = $2; if (length(visibility) > 10) visibility = substr(visibility, 1, 7) "...";
    language = $3; if (length(language) > 12) language = substr(language, 1, 9) "...";
    updated = $4; if (length(updated) > 12) updated = substr(updated, 1, 9) "...";
    printf "\033[36m%-*s\033[0m \033[37m%-10s\033[0m \033[33m%-12s\033[0m \033[35m%-12s\033[0m\n", repo_width, repo_name, visibility, language, updated
  }' | fzf --prompt="Select a repo from '$org' to clone > " --height="50%" --border --ansi \
    --header="$repo_header VISIBILITY LANGUAGE     UPDATED     " \
    --delimiter=' ' --with-nth=1,2,3,4)

  # --- 5. Clone the Repository ---
  # Proceed only if a repository was selected (fzf wasn't cancelled with Esc)
  if [ -n "$selected_repo" ]; then
    # Extract just the full repo name (e.g., "google/go-cloud")
    repo_name=$(echo "$selected_repo" | awk '{print $1}')
    # Extract just the repository's base name (e.g., "go-cloud")
    repo_basename=$(basename "$repo_name")

    # Create the base GitHub and organization directories if they don't exist
    mkdir -p "$org_dir"

    # Define the final destination path
    local final_dest="$org_dir/$repo_basename"

    echo "\nCloning $repo_name into $final_dest..."
    gh repo clone "$repo_name" "$final_dest"
  else
    echo "No repository selected."
  fi
}

# ffgn (Fuzzy Find Git Nav) - Interactively find a repository within ~/GitHub and open it in Neovim.
ffgn() {
    # The search path is always the ~/GitHub directory.
    local search_path="$HOME/GitHub"

    # Check if the GitHub directory exists.
    if [[ ! -d "$search_path" ]]; then
        echo "Directory not found: $search_path"
        echo "Please clone a repository with 'gc <org>' first."
        return 1
    fi

    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFGN_SEARCH_PATH="$search_path"

    # Find directories within ~/GitHub, limiting the depth to 2 levels (org/repo),
    # strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d --max-depth 2 . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FFGN_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'GitHub Project Finder | Press Enter to open in Neovim')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        # Open the selected directory in Neovim.
        cd "$full_path"
        # Set the terminal tab name to the repository name
        command -v ttn &>/dev/null && ttn
        nvim .
    fi
}

# fpr (Fuzzy Pull Request) - Interactively find and open one of your open GitHub PRs.
fpr() {
    # Fetch the list of open PRs assigned to you using the gh CLI.
    # The format argument creates a clean, tab-separated string with relevant info.
    local pr_list
    pr_list=$(gh search prs --author "@me" --state open --json repository,number,title,url --template '{{range .items}}{{.repository.nameWithOwner}}\t#{{.number}}\t{{.title}}\t{{.url}}{{""\n""}}{{end}}')

    # Check if the command was successful and if any PRs were returned.
    if [ -z "$pr_list" ]; then
        echo "No open pull requests found for you.";
        return 1;
    fi

    # Pipe the list of PRs into fzf for interactive selection.
    # --ansi is used to correctly render any potential colors.
    # --nth=1,2,3 tells fzf to search within the repo name, PR number, and title.
    # The selected line is stored in the 'selected_pr' variable.
    local selected_pr
    selected_pr=$(echo -e "$pr_list" | fzf \
        --prompt="Select a Pull Request to open > " \
        --height="40%" \
        --border \
        --ansi \
        --nth=1,2,3 \
        --preview 'echo -e "$(echo {} | cut -f 1-3)" | cut -c -$(tput cols)' \
        --preview-window 'top:1:wrap')

    # If a PR was selected (fzf wasn't cancelled), open its URL in the browser.
    if [ -n "$selected_pr" ]; then
        # Extract the URL (the 4th tab-separated field).
        local pr_url
        pr_url=$(echo "$selected_pr" | awk -F'\t' '{print $4}')
        # Open the URL in the default web browser.
        open "$pr_url";
    else
        echo "No pull request selected."
    fi
}

# ghpr (Git Pull Request) - Interactively find and open a GitHub PR from an organization/repository.
# If no org is provided, shows a fuzzy finder to select from local orgs.
# If no repo is provided, shows a fuzzy finder to select from org repos.
ghpr() {
  # --- 1. Handle Organization Selection ---
  local org
  if [ -z "$1" ]; then
    # No org provided, use fuzzy finder to select from local orgs
    org=$(_select_org)
    if [ -z "$org" ]; then
      echo "No organization selected."
      return 1
    fi
    echo "Selected organization: $org"
  else
    org="$1"
  fi

  # --- 2. Define Variables ---
  local repo_list
  local selected_repo
  local repo_name
  local repo_basename
  local full_repo
  local pr_list
  local selected_pr

  # --- 3. Handle Repository Selection ---
  if [ -z "$2" ]; then
    # No repo provided, fetch and select from GitHub API
    echo "Fetching repositories for '$org'..."
    repo_list=$(gh repo list "$org" --limit 1000) || return 1

    # Check if any repositories were found
    if [ -z "$repo_list" ]; then
        echo "No repositories found for organization '$org' or organization does not exist."
        return 1
    fi

    # Calculate dynamic column widths
    local max_repo_width
    max_repo_width=$(echo "$repo_list" | awk '{if (length($1) > max) max = length($1)} END {print max}')
    
    # Set minimum width of 20
    if [ "$max_repo_width" -lt 20 ]; then
      max_repo_width=20
    fi
    
    # Create header with dynamic width
    local repo_header=$(printf "%-${max_repo_width}s" "REPOSITORY")

    # Interactive repository selection with dynamic-width colors
    selected_repo=$(echo "$repo_list" | awk -v repo_width="$max_repo_width" '{
      repo_name = $1;
      visibility = $2; if (length(visibility) > 10) visibility = substr(visibility, 1, 7) "...";
      language = $3; if (length(language) > 12) language = substr(language, 1, 9) "...";
      updated = $4; if (length(updated) > 12) updated = substr(updated, 1, 9) "...";
      printf "\033[36m%-*s\033[0m \033[37m%-10s\033[0m \033[33m%-12s\033[0m \033[35m%-12s\033[0m\n", repo_width, repo_name, visibility, language, updated
    }' | fzf --prompt="Select a repo from '$org' > " --height="50%" --border --ansi \
      --header="$repo_header VISIBILITY LANGUAGE     UPDATED     " \
      --delimiter=' ' --with-nth=1,2,3,4)

    # Proceed only if a repository was selected
    if [ -n "$selected_repo" ]; then
      # Extract just the full repo name (e.g., "google/go-cloud")
      repo_name=$(echo "$selected_repo" | awk '{print $1}')
      # Extract just the repository's base name (e.g., "go-cloud")
      repo_basename=$(basename "$repo_name")
    else
      echo "No repository selected."
      return 1
    fi
  else
    repo_basename="$2"
  fi

  # --- 4. Define Full Repository Name ---
  full_repo="$org/$repo_basename"

  # --- 5. Get Pull Request List ---
  echo "Fetching pull requests for '$full_repo'..."
  pr_list=$(gh pr list --repo "$full_repo" --limit 100 --json number,title,author,url,createdAt,state --template '{{range .}}#{{.number}}\t{{.title}}\t{{.author.login}}\t{{.state}}\t{{.createdAt}}\t{{.url}}\t{{.number}}{{"\n"}}{{end}}') 
  
  if [ $? -ne 0 ]; then
    echo "Failed to fetch pull requests for '$full_repo'. Make sure the repository exists and you have access."
    return 1
  fi

  # Check if any PRs were found
  if [ -z "$pr_list" ]; then
    echo "No pull requests found for repository '$full_repo'."
    return 1
  fi

  # --- 6. Interactive PR Selection with fzf and enhanced metadata display ---
  selected_pr=$(echo "$pr_list" | awk -F'\t' '{
    pr_num = $1; if (length(pr_num) > 8) pr_num = substr(pr_num, 1, 5) "...";
    title = $2; if (length(title) > 35) title = substr(title, 1, 32) "...";
    author = $3; if (length(author) > 12) author = substr(author, 1, 9) "...";
    state = $4;
    created = $5; 
    # Format date to show just the date part (YYYY-MM-DD)
    split(created, date_parts, "T");
    created_date = date_parts[1];
    printf "\033[36m%-8s\033[0m \033[35m%-35s\033[0m \033[33m%-12s\033[0m \033[32m%-8s\033[0m \033[37m%-12s\033[0m %s\n", pr_num, title, author, state, created_date, $7
  }' | fzf \
    --prompt="Select a PR from '$full_repo' > " \
    --height="60%" \
    --border \
    --ansi \
    --delimiter=' ' \
    --nth=1,2,3,4,5 \
    --with-nth=1,2,3,4,5 \
    --header="PR #     TITLE                              AUTHOR      STATE    CREATED     " \
    --preview 'gh pr view {6} --repo '"$full_repo"' || echo "Could not load PR details"' \
    --preview-window 'right:40%')

  # --- 7. Open the Pull Request ---
  if [ -n "$selected_pr" ]; then
    # Extract the PR number (7th column)
    local pr_number
    pr_number=$(echo "$selected_pr" | awk '{print $6}')
    
    echo "Opening PR #$pr_number in browser..."
    gh pr view "$pr_number" --repo "$full_repo" --web
  else
    echo "No pull request selected."
  fi
}

# ghpra (Git Pull Request Approve) - Auto-approve a GitHub PR with LGTM comment
ghpra() {
  # --- 1. Validate Input ---
  if [ -z "$1" ]; then
    echo "Usage: ghpra <pr_url_or_number> [repo]"
    echo "Example: ghpra https://github.com/org/repo/pull/123"
    echo "Example: ghpra 123 org/repo"
    return 1
  fi

  local input="$1"
  local repo="$2"
  local pr_number
  local pr_repo

  # --- 2. Parse Input ---
  # Check if input is a URL or just a number
  if [[ "$input" =~ ^https://github\.com/.+/pull/[0-9]+.*$ ]]; then
    # It's a full URL - extract repo and PR number using sed
    pr_repo=$(echo "$input" | sed -E 's|https://github\.com/([^/]+/[^/]+)/pull/([0-9]+).*|\1|')
    pr_number=$(echo "$input" | sed -E 's|https://github\.com/([^/]+/[^/]+)/pull/([0-9]+).*|\2|')
    
    # Validate extraction worked
    if [ -z "$pr_repo" ] || [ -z "$pr_number" ]; then
      echo "Error: Failed to parse GitHub URL: $input"
      return 1
    fi
  elif [[ "$input" =~ ^[0-9]+$ ]]; then
    # It's just a PR number
    if [ -z "$repo" ]; then
      echo "Error: When providing just a PR number, you must also provide the repository."
      echo "Usage: ghpra <pr_number> <org/repo>"
      return 1
    fi
    pr_number="$input"
    pr_repo="$repo"
  else
    echo "Error: Invalid input format. Provide either a GitHub PR URL or PR number with repo."
    echo "Debug: input was '$input'"
    return 1
  fi

  # --- 3. Approve the PR ---
  echo "Approving PR #$pr_number in $pr_repo..."
  
  # Add LGTM comment and approve
  if gh pr review "$pr_number" --repo "$pr_repo" --approve --body "LGTM"; then
    echo "✅ Successfully approved PR #$pr_number with LGTM comment!"
    echo "🔗 View PR: https://github.com/$pr_repo/pull/$pr_number"
  else
    echo "❌ Failed to approve PR #$pr_number. Check your permissions and that the PR exists."
    return 1
  fi
}

# ghrao (Git Actions Open) - Interactively find and view GitHub Actions runs for a repository.
# Shows all workflow runs for the selected repository and opens them in browser.
ghrao() {
  # --- 1. Handle Organization Selection ---
  local org
  if [ -z "$1" ]; then
    # No org provided, use fuzzy finder to select from local orgs
    org=$(_select_org)
    if [ -z "$org" ]; then
      echo "No organization selected."
      return 1
    fi
    echo "Selected organization: $org"
  else
    org="$1"
  fi

  # --- 2. Define Variables ---
  local repo_list
  local selected_repo
  local repo_name
  local repo_basename
  local full_repo

  # --- 3. Handle Repository Selection ---
  if [ -z "$2" ]; then
    # No repo provided, fetch and select from GitHub API
    echo "Fetching repositories for '$org'..."
    repo_list=$(gh repo list "$org" --limit 1000) || return 1

    # Check if any repositories were found
    if [ -z "$repo_list" ]; then
        echo "No repositories found for organization '$org' or organization does not exist."
        return 1
    fi

    # Calculate dynamic column widths
    local max_repo_width
    max_repo_width=$(echo "$repo_list" | awk '{if (length($1) > max) max = length($1)} END {print max}')
    
    # Set minimum width of 20
    if [ "$max_repo_width" -lt 20 ]; then
      max_repo_width=20
    fi
    
    # Create header with dynamic width
    local repo_header=$(printf "%-${max_repo_width}s" "REPOSITORY")

    # Interactive repository selection with dynamic-width colors
    selected_repo=$(echo "$repo_list" | awk -v repo_width="$max_repo_width" '{
      repo_name = $1;
      visibility = $2; if (length(visibility) > 10) visibility = substr(visibility, 1, 7) "...";
      language = $3; if (length(language) > 12) language = substr(language, 1, 9) "...";
      updated = $4; if (length(updated) > 12) updated = substr(updated, 1, 9) "...";
      printf "\033[36m%-*s\033[0m \033[37m%-10s\033[0m \033[33m%-12s\033[0m \033[35m%-12s\033[0m\n", repo_width, repo_name, visibility, language, updated
    }' | fzf --prompt="Select a repo from '$org' > " --height="50%" --border --ansi \
      --header="$repo_header VISIBILITY LANGUAGE     UPDATED     " \
      --delimiter=' ' --with-nth=1,2,3,4)

    # Proceed only if a repository was selected
    if [ -n "$selected_repo" ]; then
      # Extract just the full repo name (e.g., "google/go-cloud")
      repo_name=$(echo "$selected_repo" | awk '{print $1}')
      # Extract just the repository's base name (e.g., "go-cloud")
      repo_basename=$(basename "$repo_name")
    else
      echo "No repository selected."
      return 1
    fi
  else
    repo_basename="$2"
  fi

  # --- 4. Define Full Repository Name ---
  full_repo="$org/$repo_basename"

  # --- 5. Get GitHub Actions for Repository ---
  echo "Fetching GitHub Actions for '$full_repo'..."
  
  # Get workflow runs for the repository (all branches, latest 100) - using simpler format first
  local raw_actions
  raw_actions=$(gh run list --repo "$full_repo" --limit 100 --json databaseId,number,status,conclusion,workflowName,headSha,headBranch,createdAt,displayTitle)
  
  if [ $? -ne 0 ]; then
    echo "Failed to fetch GitHub Actions for '$full_repo'. Make sure the repository exists and you have access."
    return 1
  fi
  
  if [ -z "$raw_actions" ] || [ "$raw_actions" = "[]" ]; then
    echo "No GitHub Actions runs found for repository '$full_repo'."
    return 1
  fi
  
  # Calculate dynamic workflow name width
  local max_workflow_width
  max_workflow_width=$(echo "$raw_actions" | jq -r '.[] | .workflowName' | awk '{if (length($0) > max) max = length($0)} END {print max}')
  
  # Set minimum width of 15
  if [ "$max_workflow_width" -lt 15 ]; then
    max_workflow_width=15
  fi

  # Process the JSON to create tab-separated format with color coding (reordered: run#, workflow, status, conclusion, branch, commit, created)
  local actions_list
  actions_list=$(echo "$raw_actions" | jq -r '
    def colorize_status: 
      if . == "completed" then "\u001b[32m" + . + "\u001b[0m"
      elif . == "in_progress" then "\u001b[33m" + . + "\u001b[0m" 
      elif . == "waiting" then "\u001b[36m" + . + "\u001b[0m"
      else "\u001b[37m" + . + "\u001b[0m"
      end;
    
    def colorize_conclusion:
      if . == "success" then "\u001b[32m" + . + "\u001b[0m"
      elif . == "failure" then "\u001b[31m" + . + "\u001b[0m"
      elif . == "cancelled" then "\u001b[33m" + . + "\u001b[0m"
      elif . == "" then "\u001b[37m-\u001b[0m"
      else "\u001b[37m" + . + "\u001b[0m"
      end;
    
    .[] | [
      ("\u001b[36m" + (.number | tostring) + "\u001b[0m"),
      (.workflowName),
      (.status | colorize_status),
      (.conclusion | colorize_conclusion), 
      ("\u001b[34m" + .headBranch + "\u001b[0m"),
      ("\u001b[33m" + (.headSha[:7]) + "\u001b[0m"),
      ("\u001b[37m" + (.createdAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M")) + "\u001b[0m"),
      .displayTitle,
      .databaseId
    ] | @tsv
  ')
  
  if [ -z "$actions_list" ]; then
    echo "No GitHub Actions runs found for repository '$full_repo'."
    return 1
  fi
  
  # --- 6. Interactive Actions Selection with Dynamic Width Formatting ---
  # Create dynamic header for workflow column
  local workflow_header=$(printf "%-${max_workflow_width}s" "WORKFLOW")
  
  # Format the actions list with proper column widths
  local formatted_actions
  formatted_actions=$(echo "$actions_list" | awk -F'\t' -v workflow_width="$max_workflow_width" '{
    run_num = $1;
    workflow = $2; 
    status = $3;
    conclusion = $4;
    branch = $5; if (length(branch) > 15) branch = substr(branch, 1, 12) "...";
    commit = $6;
    created = $7; if (length(created) > 16) created = substr(created, 1, 13) "...";
    title = $8;
    db_id = $9;
    
    printf "%-8s \\033[35m%-*s\\033[0m %-12s %-12s \\033[34m%-15s\\033[0m \\033[33m%-8s\\033[0m \\033[37m%-16s\\033[0m %s\\t%s\n", 
           run_num, workflow_width, workflow, status, conclusion, branch, commit, created, title, db_id
  }')
  
  echo
  echo "GitHub Actions for $full_repo"
  echo "────────────────────────────────────────────────────────────────────────────────────"
  printf "\\u001b[36m%-8s\\u001b[0m \\u001b[35m%s\\u001b[0m \\u001b[32m%-12s\\u001b[0m \\u001b[31m%-12s\\u001b[0m \\u001b[34m%-15s\\u001b[0m \\u001b[33m%-8s\\u001b[0m \\u001b[37m%-16s\\u001b[0m\\n" "RUN #" "$workflow_header" "STATUS" "CONCLUSION" "BRANCH" "COMMIT" "CREATED"
  echo "────────────────────────────────────────────────────────────────────────────────────"
  
  local selected_action
  selected_action=$(echo "$formatted_actions" | fzf \
    --prompt="Select a GitHub Action run > " \
    --height="70%" \
    --border \
    --ansi \
    --delimiter=$'\t' \
    --nth=1 \
    --with-nth=1)
  
  # --- 7. View Selected Action Run ---
  if [ -n "$selected_action" ]; then
    local run_id
    run_id=$(echo "$selected_action" | awk -F'\t' '{print $2}')
    local run_number
    run_number=$(echo "$selected_action" | awk -F'\t' '{print $1}' | sed 's/[^0-9]*//g')
    
    echo "Opening GitHub Action run #$run_number in browser..."
    gh run view "$run_id" --repo "$full_repo" --web
  else
    echo "No GitHub Action run selected."
  fi
}

# ghraw (Git Actions Watch) - Interactively find and watch/view GitHub Actions logs for a repository.
# If a run is in progress, it will live watch the logs. Otherwise, it shows the completed logs.
# Use -r or --read to view saved error logs in a TUI interface.
ghraw() {
  # --- Handle -r/--read flag ---
  if [[ "$1" == "-r" || "$1" == "--read" ]]; then
    local log_dir="$HOME/.config/ghraw"
    local log_file="$log_dir/latest_run.log"
    
    if [[ ! -f "$log_file" ]]; then
      echo "No log file found at $log_file"
      echo "Run 'ghraw' first to generate a log file."
      return 1
    fi
    
    echo "Opening GitHub Actions log in interactive viewer..."
    echo "────────────────────────────────────────────────────────────────"
    
    _ghraw_open_interactive_viewer "$log_file"
    return 0
  fi
  # --- 1. Handle Organization Selection ---
  local org
  if [ -z "$1" ]; then
    # No org provided, use fuzzy finder to select from local orgs
    org=$(_select_org)
    if [ -z "$org" ]; then
      echo "No organization selected."
      return 1
    fi
    echo "Selected organization: $org"
  else
    org="$1"
  fi

  # --- 2. Define Variables ---
  local repo_list
  local selected_repo
  local repo_name
  local repo_basename
  local full_repo

  # --- 3. Handle Repository Selection ---
  if [ -z "$2" ]; then
    # No repo provided, fetch and select from GitHub API
    echo "Fetching repositories for '$org'..."
    repo_list=$(gh repo list "$org" --limit 1000) || return 1

    # Check if any repositories were found
    if [ -z "$repo_list" ]; then
        echo "No repositories found for organization '$org' or organization does not exist."
        return 1
    fi

    # Calculate dynamic column widths
    local max_repo_width
    max_repo_width=$(echo "$repo_list" | awk '{if (length($1) > max) max = length($1)} END {print max}')
    
    # Set minimum width of 20
    if [ "$max_repo_width" -lt 20 ]; then
      max_repo_width=20
    fi
    
    # Create header with dynamic width
    local repo_header=$(printf "%-${max_repo_width}s" "REPOSITORY")

    # Interactive repository selection with dynamic-width colors
    selected_repo=$(echo "$repo_list" | awk -v repo_width="$max_repo_width" '{
      repo_name = $1;
      visibility = $2; if (length(visibility) > 10) visibility = substr(visibility, 1, 7) "...";
      language = $3; if (length(language) > 12) language = substr(language, 1, 9) "...";
      updated = $4; if (length(updated) > 12) updated = substr(updated, 1, 9) "...";
      printf "\033[36m%-*s\033[0m \033[37m%-10s\033[0m \033[33m%-12s\033[0m \033[35m%-12s\033[0m\n", repo_width, repo_name, visibility, language, updated
    }' | fzf --prompt="Select a repo from '$org' > " --height="50%" --border --ansi \
      --header="$repo_header VISIBILITY LANGUAGE     UPDATED     " \
      --delimiter=' ' --with-nth=1,2,3,4)

    # Proceed only if a repository was selected
    if [ -n "$selected_repo" ]; then
      # Extract just the full repo name (e.g., "google/go-cloud")
      repo_name=$(echo "$selected_repo" | awk '{print $1}')
      # Extract just the repository's base name (e.g., "go-cloud")
      repo_basename=$(basename "$repo_name")
    else
      echo "No repository selected."
      return 1
    fi
  else
    repo_basename="$2"
  fi

  # --- 4. Define Full Repository Name ---
  full_repo="$org/$repo_basename"

  # --- 5. Get GitHub Actions for Repository ---
  echo "Fetching GitHub Actions for '$full_repo'..."
  
  # Get workflow runs for the repository (all branches, latest 100) - using simpler format first
  local raw_actions
  raw_actions=$(gh run list --repo "$full_repo" --limit 100 --json databaseId,number,status,conclusion,workflowName,headSha,headBranch,createdAt,displayTitle)
  
  if [ $? -ne 0 ]; then
    echo "Failed to fetch GitHub Actions for '$full_repo'. Make sure the repository exists and you have access."
    return 1
  fi
  
  if [ -z "$raw_actions" ] || [ "$raw_actions" = "[]" ]; then
    echo "No GitHub Actions runs found for repository '$full_repo'."
    return 1
  fi
  
  # Calculate dynamic workflow name width
  local max_workflow_width
  max_workflow_width=$(echo "$raw_actions" | jq -r '.[] | .workflowName' | awk '{if (length($0) > max) max = length($0)} END {print max}')
  
  # Set minimum width of 15
  if [ "$max_workflow_width" -lt 15 ]; then
    max_workflow_width=15
  fi

  # Process the JSON to create tab-separated format with color coding (reordered: run#, workflow, status, conclusion, branch, commit, created)
  local actions_list
  actions_list=$(echo "$raw_actions" | jq -r '
    def colorize_status: 
      if . == "completed" then "\u001b[32m" + . + "\u001b[0m"
      elif . == "in_progress" then "\u001b[33m" + . + "\u001b[0m" 
      elif . == "waiting" then "\u001b[36m" + . + "\u001b[0m"
      else "\u001b[37m" + . + "\u001b[0m"
      end;
    
    def colorize_conclusion:
      if . == "success" then "\u001b[32m" + . + "\u001b[0m"
      elif . == "failure" then "\u001b[31m" + . + "\u001b[0m"
      elif . == "cancelled" then "\u001b[33m" + . + "\u001b[0m"
      elif . == "" then "\u001b[37m-\u001b[0m"
      else "\u001b[37m" + . + "\u001b[0m"
      end;
    
    .[] | [
      ("\u001b[36m" + (.number | tostring) + "\u001b[0m"),
      (.workflowName),
      (.status | colorize_status),
      (.conclusion | colorize_conclusion), 
      ("\u001b[34m" + .headBranch + "\u001b[0m"),
      ("\u001b[33m" + (.headSha[:7]) + "\u001b[0m"),
      ("\u001b[37m" + (.createdAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M")) + "\u001b[0m"),
      .displayTitle,
      .databaseId,
      .status
    ] | @tsv
  ')
  
  if [ -z "$actions_list" ]; then
    echo "No GitHub Actions runs found for repository '$full_repo'."
    return 1
  fi
  
  # --- 6. Interactive Actions Selection with Dynamic Width Formatting ---
  # Create dynamic header for workflow column
  local workflow_header=$(printf "%-${max_workflow_width}s" "WORKFLOW")
  
  # Format the actions list with proper column widths
  local formatted_actions
  formatted_actions=$(echo "$actions_list" | awk -F'\t' -v workflow_width="$max_workflow_width" '{
    run_num = $1;
    workflow = $2; 
    status = $3;
    conclusion = $4;
    branch = $5; if (length(branch) > 15) branch = substr(branch, 1, 12) "...";
    commit = $6;
    created = $7; if (length(created) > 16) created = substr(created, 1, 13) "...";
    title = $8;
    db_id = $9;
    raw_status = $10;
    
    printf "%-8s \\033[35m%-*s\\033[0m %-12s %-12s \\033[34m%-15s\\033[0m \\033[33m%-8s\\033[0m \\033[37m%-16s\\033[0m %s\\t%s\\t%s\n", 
           run_num, workflow_width, workflow, status, conclusion, branch, commit, created, title, db_id, raw_status
  }')
  
  echo
  echo "GitHub Actions for $full_repo (Watch Mode)"
  echo "────────────────────────────────────────────────────────────────────────────────────"
  printf "\033[36m%-8s\033[0m \033[35m%-${max_workflow_width}s\033[0m \033[32m%-12s\033[0m \033[31m%-12s\033[0m \033[34m%-15s\033[0m \033[33m%-8s\033[0m \033[37m%-16s\033[0m\n" "RUN #" "WORKFLOW" "STATUS" "CONCLUSION" "BRANCH" "COMMIT" "CREATED"
  echo "────────────────────────────────────────────────────────────────────────────────────"
  
  local selected_action
  selected_action=$(echo "$formatted_actions" | fzf \
    --prompt="Select a GitHub Action run to watch/view logs > " \
    --height="70%" \
    --border \
    --ansi \
    --delimiter=$'\t' \
    --nth=1 \
    --with-nth=1)
  
  # --- 7. Watch or View Selected Action Run Logs ---
  if [ -n "$selected_action" ]; then
    local run_id
    run_id=$(echo "$selected_action" | awk -F'\t' '{print $2}')
    local run_number
    run_number=$(echo "$selected_action" | awk -F'\t' '{print $1}' | sed 's/[^0-9]*//g')
    local run_status
    run_status=$(echo "$selected_action" | awk -F'\t' '{print $3}')
    
    # Create log directory if it doesn't exist
    local log_dir="$HOME/.config/ghraw"
    mkdir -p "$log_dir"
    local log_file="$log_dir/latest_run.log"
    
    echo
    if [[ "$run_status" == "in_progress" || "$run_status" == "waiting" ]]; then
      echo "🔴 Run #$run_number is currently running. Starting live watch..."
      echo "Press Ctrl+C to stop watching."
      echo "────────────────────────────────────────────────────────────────"
      
      # Live watch for in-progress runs
      gh run watch "$run_id" --repo "$full_repo"
    else
      echo "📋 Run #$run_number is completed. Fetching logs..."
      echo "────────────────────────────────────────────────────────────────"
      
      # Get the full log output for completed runs
      local log_output
      log_output=$(gh run view "$run_id" --repo "$full_repo" --log 2>&1)
      local log_exit_code=$?
      
      if [[ $log_exit_code -ne 0 ]]; then
        echo "❌ Failed to fetch logs. Error:"
        echo "$log_output"
        return 1
      fi
      
      # Always save logs (both success and failure)
      _ghraw_save_run_log "$full_repo" "$run_id" "$run_number" "$log_output"
      
      echo "✅ Logs processed and formatted. Opening interactive viewer..."
      echo "────────────────────────────────────────────────────────────────"
      
      # Always open interactive viewer for completed runs
      _ghraw_open_interactive_viewer "$log_file"
    fi
  else
    echo "No GitHub Action run selected."
  fi
}

# Helper function to save run logs with metadata (both success and failure)
_ghraw_save_run_log() {
  local repo="$1"
  local run_id="$2" 
  local run_number="$3"
  local log_content="$4"
  
  local log_dir="$HOME/.config/ghraw"
  local log_file="$log_dir/latest_run.log"
  
  # Get additional metadata
  local run_details
  run_details=$(gh run view "$run_id" --repo "$repo" --json workflowName,headBranch,headSha,conclusion,status,createdAt,htmlUrl,displayTitle 2>/dev/null)
  
  local workflow_name=$(echo "$run_details" | jq -r '.workflowName // "Unknown Workflow"')
  local branch=$(echo "$run_details" | jq -r '.headBranch // "Unknown Branch"')
  local commit_sha=$(echo "$run_details" | jq -r '.headSha // "Unknown Commit"')
  local conclusion=$(echo "$run_details" | jq -r '.conclusion // "Unknown"')
  local run_status=$(echo "$run_details" | jq -r '.status // "Unknown"')
  local created_at=$(echo "$run_details" | jq -r '.createdAt // "Unknown"')
  local html_url=$(echo "$run_details" | jq -r '.htmlUrl // "Unknown"')
  local display_title=$(echo "$run_details" | jq -r '.displayTitle // "No title"')
  
  # Determine status icon and colors
  local status_icon="✅"
  local status_color="🟢"
  if [[ "$conclusion" == "failure" ]]; then
    status_icon="❌"
    status_color="🔴"
  elif [[ "$conclusion" == "cancelled" ]]; then
    status_icon="🚫"
    status_color="🟡"
  elif [[ "$conclusion" == "success" ]]; then
    status_icon="✅"
    status_color="🟢"
  fi
  
  # Format the log content with better structure and colors
  local formatted_content
  formatted_content=$(_ghraw_format_log_content "$log_content")
  
  # Create enhanced log file with beautiful metadata header
  cat > "$log_file" << EOF
╭────────────────────────────────────────────────────────────────────────────────────╮
│ $status_icon GitHub Actions Run Log - $status_color $conclusion                                     │
╰────────────────────────────────────────────────────────────────────────────────────╯

📋 METADATA
╭─────────────────────────────────────────────────────────────────────────────────────
│ Repository: $repo
│ Workflow:   $workflow_name  
│ Title:      $display_title
│ Run #:      $run_number (ID: $run_id)
│ Branch:     $branch
│ Commit:     ${commit_sha:0:7}
│ Status:     $run_status → $conclusion
│ Created:    $created_at
│ URL:        $html_url
│ Generated:  $(date '+%Y-%m-%d %H:%M:%S')
╰─────────────────────────────────────────────────────────────────────────────────────

🚀 WORKFLOW LOGS
╭─────────────────────────────────────────────────────────────────────────────────────

$formatted_content

╰─────────────────────────────────────────────────────────────────────────────────────
EOF

  echo "Run log saved to: $log_file"
}

# Helper function to format log content with colors and structure
_ghraw_format_log_content() {
  local content="$1"
  local current_job=""
  local current_step=""
  local formatted=""
  
  # Process line by line for better formatting
  while IFS= read -r line; do
    # Skip empty lines at the beginning
    [[ -z "$line" ]] && continue
    
    # Extract job, step, and timestamp from GitHub Actions format
    # Using IFS to split by tabs instead of regex (more portable for zsh)
    IFS=$'\t' read -r job step log_line <<< "$line"
    
    if [[ -n "$job" && -n "$step" && -n "$log_line" ]]; then
      
      # New job detected
      if [[ "$job" != "$current_job" ]]; then
        [[ -n "$current_job" ]] && formatted+="\n"
        formatted+="\n🏗️  JOB: $job\n"
        formatted+="├─────────────────────────────────────────────────────────────────────────────────\n"
        current_job="$job"
        current_step=""
      fi
      
      # New step detected  
      if [[ "$step" != "$current_step" && "$step" != "UNKNOWN STEP" ]]; then
        [[ -n "$current_step" ]] && formatted+="\n"
        formatted+="│ 🔧 STEP: $step\n"
        formatted+="│ ┌───────────────────────────────────────────────────────────────────────────────\n"
        current_step="$step"
      fi
      
      # Format the actual log line with colors
      local colored_line
      colored_line=$(_ghraw_colorize_log_line "$log_line")
      formatted+="│ │ $colored_line\n"
    else
      # Handle lines that don't match the expected format
      local colored_line
      colored_line=$(_ghraw_colorize_log_line "$line")
      formatted+="│ │ $colored_line\n"
    fi
  done <<< "$content"
  
  echo -e "$formatted"
}

# Helper function to add colors to log lines based on content
_ghraw_colorize_log_line() {
  local line="$1"
  
  # Extract timestamp if present using sed instead of regex
  local timestamp=""
  local content=""
  
  # Check if line starts with timestamp pattern
  if echo "$line" | grep -q '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]*Z'; then
    timestamp=$(echo "$line" | sed -n 's/^\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]*Z\).*/\1/p')
    content=$(echo "$line" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]*Z//')
    
    # Format timestamp in a more readable way
    local formatted_time
    formatted_time=$(echo "$timestamp" | sed 's/T/ /' | sed 's/\.[0-9]*Z//')
    
    # Colorize content based on patterns
    if echo "$content" | grep -q '##\[error\]'; then
      echo -e "\033[90m[$formatted_time]\033[0m \033[31m$content\033[0m"  # Red for errors
    elif echo "$content" | grep -q '##\[warning\]'; then
      echo -e "\033[90m[$formatted_time]\033[0m \033[33m$content\033[0m"  # Yellow for warnings
    elif echo "$content" | grep -q '##\[group\]'; then
      echo -e "\033[90m[$formatted_time]\033[0m \033[36m$content\033[0m"  # Cyan for groups
    elif echo "$content" | grep -q '##\[command\]'; then
      echo -e "\033[90m[$formatted_time]\033[0m \033[35m$content\033[0m"  # Magenta for commands
    elif echo "$content" | grep -q 'shell:'; then
      echo -e "\033[90m[$formatted_time]\033[0m \033[34m$content\033[0m"  # Blue for shell info
    else
      echo -e "\033[90m[$formatted_time]\033[0m $content"  # Default
    fi
  else
    # No timestamp, just colorize based on content
    if echo "$line" | grep -q '##\[error\]'; then
      echo -e "\033[31m$line\033[0m"  # Red for errors
    elif echo "$line" | grep -q '##\[warning\]'; then
      echo -e "\033[33m$line\033[0m"  # Yellow for warnings  
    elif echo "$line" | grep -q '##\[group\]'; then
      echo -e "\033[36m$line\033[0m"  # Cyan for groups
    else
      echo "$line"  # Default
    fi
  fi
}

# Interactive grep TUI for GitHub Actions logs
_ghraw_open_interactive_viewer() {
  local log_file="$1"
  
  echo "🔍 Opening Interactive Grep TUI for GitHub Actions logs..."
  echo
  
  # First choice: ripgrep + fzf (best interactive grep experience)
  if command -v rg &> /dev/null && command -v fzf &> /dev/null; then
    echo "🚀 Using ripgrep + fzf (Interactive Grep TUI)"
    echo "Commands:"
    echo "  • Start typing to search/filter logs"
    echo "  • Ctrl+F: Start search mode"
    echo "  • Ctrl+R: Toggle regex mode"  
    echo "  • Tab: Multi-select lines"
    echo "  • Enter: View selected line(s) in detail"
    echo "  • Esc: Exit"
    echo "────────────────────────────────────────────────────────────────"
    
    # Use fzf with ripgrep for real-time searching
    fzf --ansi \
      --bind "start:reload:cat '$log_file'" \
      --bind "change:reload:rg --color=always --line-number --no-heading --smart-case {q} '$log_file' || cat '$log_file'" \
      --bind "ctrl-f:unbind(change)+change-prompt(🔍 Search: )+disable-search" \
      --bind "ctrl-r:toggle-search" \
      --bind "enter:execute:echo {} | cut -d: -f2- | bat --color=always --style=plain --paging=always" \
      --preview "echo {} | cut -d: -f1 | xargs -I {} sed -n '{},+5p' '$log_file' | bat --color=always --style=numbers --highlight-line=1" \
      --preview-window "right:40%:wrap" \
      --header "🔍 GitHub Actions Log Interactive Search | Ctrl+F: Search | Ctrl+R: Regex | Enter: Detail View | Esc: Exit" \
      --prompt "📝 Filter: " \
      --pointer "▶" \
      --marker "✓" \
      --height="90%" \
      --border="rounded" \
      --color="header:bold:blue,prompt:green,pointer:red,marker:yellow"
  
  # Second choice: fzf with basic search (if no ripgrep)
  elif command -v fzf &> /dev/null; then
    echo "📝 Using fzf (Basic Interactive Search)"
    echo "Commands: Start typing to filter, Enter to select, Esc to exit"
    echo "────────────────────────────────────────────────────────────────"
    
    cat "$log_file" | fzf --ansi \
      --bind "enter:execute:echo {} | bat --color=always --style=plain --paging=always" \
      --preview "echo {} | grep -o '[0-9]*' | head -1 | xargs -I {} sed -n '{},+3p' '$log_file'" \
      --preview-window "right:40%:wrap" \
      --header "GitHub Actions Log Search | Type to filter | Enter for details" \
      --prompt "🔍 Search: " \
      --height="90%" \
      --border="rounded"
  
  # Third choice: less with search (reliable fallback)
  elif command -v less &> /dev/null; then
    echo "📖 Using less (Search with / and n/N navigation)"
    echo "Commands: '/' search, 'n' next, 'N' previous, 'q' quit, 'G' end, 'g' start"
    echo "────────────────────────────────────────────────────────────────"
    less -R -i -# 10 -j 10 "$log_file"
  
  # Fallback: basic output with bat coloring
  else
    echo "📄 Using basic output (install fzf and ripgrep for better experience)"
    echo "────────────────────────────────────────────────────────────────"
    if command -v bat &> /dev/null; then
      bat "$log_file" --color=always --paging=always --style=numbers,changes,header
    else
      cat "$log_file"
    fi
  fi
  
  echo
  echo "💡 For the best experience, install ripgrep and fzf:"
  echo "   brew install ripgrep fzf"
}

# Git branch function for prompt (loaded always for prompt)
git_branch() {
    git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

# ghro (Git Repository Open) - Interactively find and open a GitHub repository from an organization in browser.
# If no org is provided, shows a fuzzy finder to select from local orgs.
ghro() {
  # --- 1. Handle Organization Selection ---
  local org
  if [ -z "$1" ]; then
    # No org provided, use fuzzy finder to select from local orgs
    org=$(_select_org)
    if [ -z "$org" ]; then
      echo "No organization selected."
      return 1
    fi
    echo "Selected organization: $org"
  else
    org="$1"
  fi

  # --- 2. Define Variables ---
  local repo_list
  local selected_repo
  local repo_name
  local repo_url

  # --- 3. Get Repository List ---
  # Use gh to list repos. If it fails, exit.
  echo "Fetching repositories for '$org'..."
  repo_list=$(gh repo list "$org" --limit 1000) || return 1

  # Check if any repositories were found
  if [ -z "$repo_list" ]; then
      echo "No repositories found for organization '$org' or organization does not exist."
      return 1
  fi

  # --- 4. Calculate dynamic column widths ---
  # Get the maximum repository name length
  local max_repo_width
  max_repo_width=$(echo "$repo_list" | awk '{if (length($1) > max) max = length($1)} END {print max}')
  
  # Set minimum width of 20
  if [ "$max_repo_width" -lt 20 ]; then
    max_repo_width=20
  fi
  
  # Create header with dynamic width
  local repo_header=$(printf "%-${max_repo_width}s" "REPOSITORY")
  
  # --- 5. Interactive Selection with fzf and dynamic-width colors ---
  selected_repo=$(echo "$repo_list" | awk -v repo_width="$max_repo_width" '{
    repo_name = $1;
    visibility = $2; if (length(visibility) > 10) visibility = substr(visibility, 1, 7) "...";
    language = $3; if (length(language) > 12) language = substr(language, 1, 9) "...";
    updated = $4; if (length(updated) > 12) updated = substr(updated, 1, 9) "...";
    printf "\033[36m%-*s\033[0m \033[37m%-10s\033[0m \033[33m%-12s\033[0m \033[35m%-12s\033[0m\n", repo_width, repo_name, visibility, language, updated
  }' | fzf --prompt="Select a repo from '$org' to open in browser > " --height="50%" --border --ansi \
    --header="$repo_header VISIBILITY LANGUAGE     UPDATED     " \
    --delimiter=' ' --with-nth=1,2,3,4)

  # --- 5. Open the Repository in Browser ---
  # Proceed only if a repository was selected (fzf wasn't cancelled with Esc)
  if [ -n "$selected_repo" ]; then
    # Extract just the full repo name (e.g., "google/go-cloud")
    repo_name=$(echo "$selected_repo" | awk '{print $1}')
    # Construct the GitHub URL
    repo_url="https://github.com/$repo_name"
    
    echo "Opening $repo_name in browser..."
    open "$repo_url"
  else
    echo "No repository selected."
  fi
}

# Git status function for prompt (loaded always for prompt)
# FIXED: Use different variable name to avoid conflict with zsh's read-only 'status'
git_status() {
    local git_status_info=""
    # Check for uncommitted changes
    if ! git diff --quiet 2>/dev/null; then
        git_status_info+="*"
    fi
    # Check for untracked files
    if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
        git_status_info+="?"
    fi
    # Check for staged changes
    if ! git diff --cached --quiet 2>/dev/null; then
        git_status_info+="+"
    fi
    [[ -n "$git_status_info" ]] && echo " [$git_status_info]"
}
