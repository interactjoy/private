pip install insightface

#!/bin/bash

echo "Starting Stable Diffusion Workspace..."

# Run the startup script with error checking
if ! sudo -u creativeteam bash /notebooks/private/webui.sh; then
    echo -e "\033[1;31mError: Failed to start Stable Diffusion Workspace. Please check the webui.sh script.\033[0m"
    exit 1
fi

# Progress bar to show startup
echo -e "\033[1;34m\nStarting up...\033[0m"
progress_bar_width=50
for ((i = 1; i <= progress_bar_width; i++)); do
    sleep 0.1  # Adjust sleep duration if needed to match the startup time
    progress=$((i * 2))
    printf "\r[%-${progress_bar_width}s] %d%%" "#" "$progress"
done
echo -e "\n"

echo -e "\033[1;34m
Startup complete. Please check the logs for the Gradio public link.\033[0m"
