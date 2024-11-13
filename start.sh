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

# Wait for the Gradio link to appear in the log
echo "Waiting for Gradio public link..."
link_found=false
timeout=60  # Maximum time to wait for the link (in seconds)
elapsed=0

while [ "$elapsed" -lt "$timeout" ]; do
    if grep -q 'http.*gradio.*' /notebooks/private/webui_output.log; then
        link_found=true
        break
    fi
    sleep 2
    elapsed=$((elapsed + 2))
    # Update progress bar while waiting
    progress=$((elapsed * 100 / timeout))
    printf "\r\033[1;34mWaiting: [%-${progress_bar_width}s] %d%%\033[0m" "#" "$progress"
done
echo ""

# Display the Gradio public link if found
if [ "$link_found" = true ]; then
    echo -e "\033[1;34m\n************************************************************\033[0m"
    echo -e "\033[1;34m* \033[1;97mYour Stable Diffusion Workspace is ready!\033[0m"
    echo -e "\033[1;34m* \033[1;97mUse the Public Gradio Link below to access it:\033[0m"
    echo -e "\033[1;34m* \033[1;97m$(grep -o 'http.*gradio.*' /notebooks/private/webui_output.log)\033[0m"
    echo -e "\033[1;34m************************************************************\033[0m"
else
    echo -e "\033[1;31mError: Could not find the Gradio public link within the timeout period.\033[0m"
    echo -e "\033[1;31mPlease check /notebooks/private/webui_output.log for errors.\033[0m"
fi
