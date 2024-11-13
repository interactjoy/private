#!/bin/bash

# Create 'creativeteam' user and add to sudo group
echo "Setting up 'creativeteam' user..."
sudo adduser --disabled-password --gecos "" creativeteam || echo "User 'creativeteam' already exists."
sudo usermod -aG sudo creativeteam

# Ensure proper ownership of the repository and all files
sudo chown -R creativeteam:creativeteam /notebooks/private

# Switch to the cloned directory
cd /notebooks/private

# Mark the repository as a safe directory for Git to avoid dubious ownership error
su - creativeteam -c "git config --global --add safe.directory /notebooks/private"

echo "Swapping to 'creativeteam' user..."
su - creativeteam -c "
cd /notebooks/private

echo 'Starting Stable Diffusion Workspace...'

# Run the startup script with error checking
if ! bash /notebooks/private/webui.sh; then
    echo -e '\033[1;31mError: Failed to start Stable Diffusion Workspace. Please check the webui.sh script.\033[0m'
    exit 1
fi

# Progress bar to show startup
echo -e '\033[1;34m\nStarting up...\033[0m'
progress_bar_width=50
for ((i = 1; i <= progress_bar_width; i++)); do
    sleep 0.1  # Adjust sleep duration if needed to match the startup time
    progress=$((i * 2))
    printf '\r[%-${progress_bar_width}s] %d%%' '#' '$progress'
done
echo -e '\n'

echo -e '\033[1;34m
Startup complete. Please check the logs for the Gradio public link.\033[0m'
"
