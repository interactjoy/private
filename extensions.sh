#!/bin/bash

# Function to prompt the user to enter the GitHub token until valid or quit
prompt_for_token() {
    while true; do
        read -p "Please enter your GITHUB_TOKEN (or type 'q' to quit): " GITHUB_TOKEN
        if [ "$GITHUB_TOKEN" == "q" ]; then
            echo "Quitting..."
            exit 0
        fi

        # Test the token by attempting to access the GitHub API
        echo "Testing GITHUB_TOKEN..."
        response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
        
        if [ "$response" -eq 200 ]; then
            echo "Token is valid."
            break
        else
            echo "Error: Invalid token. Please try again."
        fi
    done
}

# Prompt the user for the GitHub token
prompt_for_token

# Clone the repository using the token
REPO_URL="https://$GITHUB_TOKEN@github.com/interactjoy/Scripts"
INSTALL_DIR="/notebooks/private/Install"

mkdir -p "$INSTALL_DIR"

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Repository already exists. Skipping clone."
else
    echo "Cloning repository..."
    GIT_ASKPASS_SCRIPT=$(mktemp)
    echo "#!/bin/bash" > "$GIT_ASKPASS_SCRIPT"
    echo "echo \"$GITHUB_TOKEN\"" >> "$GIT_ASKPASS_SCRIPT"
    chmod +x "$GIT_ASKPASS_SCRIPT"

    GIT_ASKPASS="$GIT_ASKPASS_SCRIPT" git clone "$REPO_URL" "$INSTALL_DIR" || {
        echo "Error: Failed to clone the repository. Please check your token and internet connection."
        exit 1
    }

    # Clean up the temporary script
    rm -f "$GIT_ASKPASS_SCRIPT"
    
    echo "Repository cloned successfully."
fi

# Ensure we're working with creativeteam permissions
sudo -u creativeteam bash << EOF

# Function to run a script and handle errors
run_script() {
    if [ -f "\$1" ]; then
        echo "Running \$(basename \"\$1\")..."
        chmod +x "\$1"
        "\$1" || {
            echo "Error: Failed to run \$(basename \"\$1\"). Please check the script for issues."
            return 1
        }
        echo "Successfully ran \$(basename \"\$1\")."
    else
        echo "Error: Script \$1 not found."
    fi
}

# Run the downloaded scripts
SCRIPTS=(
    "install_controlnet.sh"
    "install_adetailer.sh"
    "install_sd_dynamic_prompts.sh"
    "install_wildcards.sh"
    "download_specific_models.sh"
    "install_vae_model.sh"
    "install_lora_models.sh"
)

for script_name in "\${SCRIPTS[@]}"; do
    script_path="${INSTALL_DIR}/\${script_name}"
    if [ -f "\$script_path" ]; then
        run_script "\$script_path"
        echo "\$(basename \"\$script_path\") is available."
    else
        echo "Error: \$script_path was not found or downloaded correctly."
        exit 1
    fi
done

# Upgrade gdown using virtual environment and handle errors
echo "Upgrading gdown..."
if /notebooks/private/venv/bin/pip install --upgrade gdown; then
    echo "Successfully upgraded gdown."
else
    echo "Error: Failed to upgrade gdown. Please ensure pip is installed and try again."
fi

# Add permission for start.sh script
chmod +x /notebooks/private/start.sh

# Prompt the user if they want to run start.sh
read -p "Do you want to run start.sh now? (Y/N): " run_start
if [[ "\$run_start" =~ ^[Yy]$ ]]; then
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
