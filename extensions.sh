#!/bin/bash

# Ensure the 'creativeteam' user exists, create if missing
if ! id "creativeteam" &>/dev/null; then
    echo "Setting up environment..."
    sudo useradd -m creativeteam
fi

# Prompt user for GitHub token
prompt_for_token() {
    while true; do
        read -p "Enter your GitHub token (or type 'q' to quit): " GITHUB_TOKEN
        if [ "$GITHUB_TOKEN" == "q" ]; then
            echo "Exiting..."
            exit 0
        fi

        # Validate the GitHub token
        response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
        if [ "$response" -eq 200 ]; then
            echo -e "\e[32mGitHub token validated.\e[0m"
            break
        else
            echo -e "\e[31mInvalid token, please try again.\e[0m"
        fi
    done
}

prompt_for_token

# Clone the repository
REPO_URL="https://$GITHUB_TOKEN@github.com/interactjoy/Scripts"
INSTALL_DIR="/notebooks/private/Install"

mkdir -p "$INSTALL_DIR"

if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "\e[33mRepository already exists. Skipping clone.\e[0m"
else
    echo "Cloning repository..."
    GIT_ASKPASS_SCRIPT=$(mktemp)
    echo -e "#!/bin/bash\necho \"$GITHUB_TOKEN\"" > "$GIT_ASKPASS_SCRIPT"
    chmod +x "$GIT_ASKPASS_SCRIPT"

    GIT_ASKPASS="$GIT_ASKPASS_SCRIPT" git clone -q "$REPO_URL" "$INSTALL_DIR" || {
        echo -e "\e[31mError: Could not clone repository. Check your token or internet connection.\e[0m"
        exit 1
    }
    rm -f "$GIT_ASKPASS_SCRIPT"
    echo -e "\e[32mRepository cloned successfully.\e[0m"
fi

# Initialize error log
ERROR_LOG="/notebooks/private/error_log.txt"
> "$ERROR_LOG"

# Upgrade gdown and pip
echo -e "\e[34mUpgrading gdown and pip...\e[0m"
if /notebooks/private/venv/bin/pip install --upgrade pip gdown; then
    echo -e "\e[32mgdown and pip upgraded successfully.\e[0m"
else
    echo -e "\e[31mError: Failed to upgrade gdown and/or pip. Please check your setup.\e[0m"
    echo "Error in upgrading gdown and/or pip" >> "$ERROR_LOG"
fi

# Fix gdown CLI issue by reinstalling gdown globally
echo -e "\e[34mReinstalling gdown globally to fix CLI issue...\e[0m"
if sudo /notebooks/private/venv/bin/pip install --force-reinstall gdown; then
    echo -e "\e[32mgdown reinstalled successfully.\e[0m"
else
    echo -e "\e[31mError: Failed to reinstall gdown. Please check your setup.\e[0m"
    echo "Error in reinstalling gdown" >> "$ERROR_LOG"
fi

# Clear pip cache to prevent dependency conflicts
echo -e "\e[34mClearing pip cache to prevent dependency conflicts...\e[0m"
if /notebooks/private/venv/bin/pip cache purge; then
    echo -e "\e[32mPip cache cleared successfully.\e[0m"
else
    echo -e "\e[31mError: Failed to clear pip cache. Please check your setup.\e[0m"
    echo "Error in clearing pip cache" >> "$ERROR_LOG"
fi

# Function to run scripts as 'creativeteam' user
run_script_as_creativeteam() {
    script_path="$1"

    if [ -f "$script_path" ]; then
        sudo chown creativeteam:creativeteam "$script_path"
        sudo chmod u+x "$script_path"
    else
        echo -e "\e[33mWarning: $script_path not found. Skipping...\e[0m"
        echo "Error: $script_path not found" >> "$ERROR_LOG"
        return 1
    fi

    echo -e "\e[34mRunning $(basename "$script_path")...\e[0m"
    if ! sudo -u creativeteam bash -c "cd $(dirname "$script_path") && ./$(basename "$script_path")"; then
        echo -e "\e[31mError: $(basename "$script_path") failed. Please check for issues.\e[0m"
        echo "Error in $(basename "$script_path"): $(tail -n 5 /notebooks/private/error_log.txt)" >> "$ERROR_LOG"
    else
        echo -e "\e[32mCompleted $(basename "$script_path").\e[0m"
    fi
}

# Run installation scripts with progress bars
SCRIPTS=(
    "install_controlnet.sh"
    "install_adetailer.sh"
    "install_sd_dynamic_prompts.sh"
    "install_wildcards.sh"
    "download_specific_models.sh"
    "install_vae_model.sh"
    "install_lora_models.sh"
)

for script_name in "${SCRIPTS[@]}"; do
    script_path="${INSTALL_DIR}/${script_name}"
    echo -e "\e[34m[===== Running: $(basename "$script_path") =====]\e[0m"
    run_script_as_creativeteam "$script_path"
    echo -e "\e[34m[===== Completed: $(basename "$script_path") =====]\e[0m"
    sleep 1

    # Check if the specific directory contains the expected files after running the script
    case "$script_name" in
        "download_specific_models.sh")
            MODELS_DIR="/notebooks/private/models/Stable-diffusion"
            if [ -d "$MODELS_DIR" ] && [ "$(ls -A "$MODELS_DIR")" ]; then
                echo -e "\e[32mModels directory is populated as expected.\e[0m"
            else
                echo -e "\e[31mError: Models directory is empty after running $script_name. Please check the script or download process.\e[0m"
                echo "Error: Models directory is empty after running $script_name" >> "$ERROR_LOG"
            fi
            ;;
    esac

done

# Set permissions for start.sh
if [ -f "/notebooks/private/start.sh" ]; then
    chmod +x /notebooks/private/start.sh
else
    echo -e "\e[31mError: start.sh not found.\e[0m"
    echo "Error: start.sh not found" >> "$ERROR_LOG"
fi

# Prompt user to run start.sh
read -p "Do you want to run start.sh now? (Y/N): " run_start
if [[ "$run_start" =~ ^[Yy]$ ]]; then
    echo -e "\e[34mRunning start.sh...\e[0m"
    if ! sudo -u creativeteam bash -c "cd /notebooks/private && ./start.sh"; then
        echo -e "\e[31mError: start.sh failed. Please check for issues.\e[0m"
        echo "Error in start.sh" >> "$ERROR_LOG"
        exit 1
    else
        echo -e "\e[32mstart.sh completed successfully.\e[0m"
    fi
else
    echo -e "\e[33mSkipping start.sh.\e[0m"
fi

# Final message
echo -e "\e[32mInstallation complete.\e[0m"
if [ -s "$ERROR_LOG" ]; then
    echo -e "\e[31mThe following errors occurred during installation:\e[0m"
    cat "$ERROR_LOG"
    echo -e "\e[31mPlease review the error log for more details.\e[0m"
else
    echo -e "\e[32mNo errors encountered during installation.\e[0m"
fi
