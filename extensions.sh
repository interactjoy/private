#!/bin/bash

# Function to prompt the user to enter the GitHub token until valid or quit
prompt_for_token() {
    while true; do
        read -p "Please enter your GITHUB_TOKEN (or type 'q' to quit): " GITHUB_TOKEN
        if [ "$GITHUB_TOKEN" == "q" ]; then
            echo "Quitting..."
            exit 0
        fi

        # Test the token by attempting to access the repository
        echo "Testing GITHUB_TOKEN..."
        if git ls-remote https://"$GITHUB_TOKEN"@github.com/interactjoy/Scripts &>/dev/null; then
            echo "Token is valid."
            break
        else
            echo "Error: Invalid token. Please try again."
        fi
    done
}

# Prompt the user for the GitHub token
prompt_for_token

# Ensure we're working with creativeteam permissions
sudo -u creativeteam bash << EOF

# Clone the repository using the token
REPO_URL="https://github.com/interactjoy/Scripts"

mkdir -p /notebooks/private/Install

if [ -d "/notebooks/private/Install/.git" ]; then
    echo "Repository already exists. Skipping clone."
else
    echo "Cloning repository..."
    git clone https://"$GITHUB_TOKEN"@github.com/interactjoy/Scripts /notebooks/private/Install || {
        echo "Error: Failed to clone the repository. Please check your token and internet connection."
        exit 1
    }
    echo "Repository cloned successfully."
fi

# Function to show progress bar
show_progress_bar() {
    local duration=$1
    local interval=1
    local progress=0

    echo -n "["
    while [ $progress -lt $duration ]; do
        echo -n "#"
        sleep $interval
        progress=$((progress + interval))
    done
    echo "]"
}

# Function to run a script and handle errors
run_script() {
    if [ -f "$1" ]; then
        echo "Running $(basename "$1")..."
        chmod +x "$1"
        show_progress_bar 10
        "$1" || {
            echo "Error: Failed to run $1. Please check the script for issues."
            return 1
        }
        echo "Successfully ran $(basename "$1")."
    else
        echo "Error: Script $1 not found."
    fi
}

# Run the downloaded scripts
SCRIPTS=(
    "/notebooks/private/Install/install_controlnet.sh"
    "/notebooks/private/Install/install_adetailer.sh"
    "/notebooks/private/Install/install_sd_dynamic_prompts.sh"
    "/notebooks/private/Install/install_wildcards.sh"
    "/notebooks/private/Install/download_specific_models.sh"
    "/notebooks/private/Install/install_vae_model.sh"
    "/notebooks/private/Install/install_lora_models.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "Skipping $(basename "$script") as it already exists."
    else
        run_script "$script"
    fi
    if [ ! -f "$script" ]; then
        echo "Error: $script was not downloaded correctly or is missing."
        exit 1
    fi
    echo "$(basename "$script") is available."
done

# Upgrade gdown using virtual environment and handle errors
echo "Upgrading gdown..."
show_progress_bar 10
if /notebooks/private/venv/bin/pip install --upgrade gdown; then
    echo "Successfully upgraded gdown."
else
    echo "Error: Failed to upgrade gdown. Please ensure pip is installed and try again."
fi

# Add permission for start.sh script
chmod +x /notebooks/private/start.sh

# Prompt the user if they want to run start.sh
read -p "Do you want to run start.sh now? (Y/N): " run_start
if [[ "$run_start" =~ ^[Yy]$ ]]; then
    echo "Running start.sh..."
    /notebooks/private/start.sh || {
        echo "Error: Failed to run start.sh. Please check the script for issues."
        exit 1
    }
    echo "Successfully ran start.sh."
else
    echo "Skipping start.sh execution."
fi

# Final message to user
echo "All scripts have been processed. Please review any error messages above for failed installations."

EOF
