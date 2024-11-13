#!/bin/bash

# Function to prompt for GitHub credentials
get_github_credentials() {
    echo "Please enter your GitHub login details."
    read -p "GitHub Username: " GITHUB_USERNAME
    read -s -p "GitHub Password: " GITHUB_PASSWORD
    echo ""  # New line after password input
}

# Prompt user for GitHub credentials
get_github_credentials

# Clone the repository using login credentials
REPO_URL="https://github.com/interactjoy/Scripts"

mkdir -p /notebooks/private/Install

git clone https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/interactjoy/Scripts /notebooks/private/Install || {
    echo "Error: Failed to clone the repository. Please check your credentials and internet connection."
    exit 1
}

echo "Repository cloned successfully."

# Function to run a script and handle errors
run_script() {
    if [ -f "$1" ]; then
        chmod +x "$1"
        "$1" || {
            echo "Error: Failed to run $1. Please check the script for issues."
            return 1
        }
        echo "Successfully ran $1."
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
    run_script "$script"
done

# Upgrade gdown and handle errors
if pip install --upgrade gdown; then
    echo "Successfully upgraded gdown."
else
    echo "Error: Failed to upgrade gdown. Please ensure pip is installed and try again."
fi

# Final message to user
echo "All scripts have been processed. Please review any error messages above for failed installations."
