#!/bin/bash

# --- Helper function to clone or update a repo ---
clone_or_update_repo() {
    local repo_url="$1"
    local target_dir="$2"

    if [ -d "$target_dir/.git" ]; then
        echo "Repository already exists in $target_dir. Pulling latest changes..."
        git -C "$target_dir" pull
    else
        echo "Cloning $repo_url into $target_dir..."
        git clone "$repo_url" "$target_dir"
    fi
}

# --- Add entries to /etc/hosts if they don't exist ---
echo "Checking /etc/hosts entries..."
hosts_entries=(
    "127.0.0.1 farmacia.local"
    "127.0.0.1 intranet.farmacia.local"
    "127.0.0.1 escuta.farmacia.local"
    "127.0.0.1 phpmyadmin.farmacia.local"
)

for entry in "${hosts_entries[@]}"; do
    if ! grep -q "$entry" /etc/hosts; then
        echo "$entry" | sudo tee -a /etc/hosts >/dev/null
        echo "Added: $entry"
    else
        echo "Already exists: $entry"
    fi
done

# --- Navigate to script directory ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || exit 1

# --- Create directory structure ---
echo "Creating directories..."
mkdir -p \
    ./escuta-website/html/wp-content/{themes,plugins} \
    ./institutional-website/html/wp-content/{themes,plugins} \
    ./intranet-website/html/wp-content/{themes,plugins} \
    ./reverse-proxy \
    ./db \
    ./.vscode

# --- Clone or update themes ---
echo "Updating themes..."
clone_or_update_repo \
    https://github.com/suportefafar/escuta-astra-child-theme.git \
    ./escuta-website/html/wp-content/themes/escuta-astra-child-theme

clone_or_update_repo \
    https://github.com/suportefafar/institutional-astra-child-theme.git \
    ./institutional-website/html/wp-content/themes/institutional-astra-child-theme

clone_or_update_repo \
    https://github.com/suportefafar/intranet-astra-child-theme.git \
    ./intranet-website/html/wp-content/themes/intranet-astra-child-theme

# --- Clone or update CF7 CRUD plugin ---
echo "Updating plugins..."
clone_or_update_repo \
    https://github.com/suportefafar/fafar-cf7crud.git \
    ./escuta-website/html/wp-content/plugins/fafar-cf7crud

# (Optional: Symlink to avoid duplication if needed)
# ln -sf ../../../../escuta-website/html/wp-content/plugins/fafar-cf7crud \
#    ./institutional-website/html/wp-content/plugins/fafar-cf7crud

# Pull from service-infra
echo "Pulling from service-infra repo"
git pull

# --- Start Docker ---
echo "Starting Docker containers..."
docker compose --env-file=.env -f compose.yaml -f compose.dev.yaml up --build