#!/bin/bash

# Enable error handling
set -e

# Function to display error message and exit
error_exit() {
    echo "Error on line $1: $2"
    exit 1
}

# Trap any command that exits with a non-zero status
trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

# Function to display a progress bar
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local progress=$(( (current * width) / total ))
    local remainder=$(( width - progress ))
    printf "
["
    for ((i=0; i<progress; i++)); do printf "#"; done
    for ((i=0; i<remainder; i++)); do printf "-"; done
    printf "] %d%%" $(( (current * 100) / total ))
}

# Update system and install dependencies
echo -e "\033[1;34mWelcome to your Interact Joy Stable Diffusion Workplace.\033[0m"
echo -e "\033[1;34mUse the Public Gradio Link at the end of the process to access your Stable Diffusion Workplace in your browser.\033[0m"
echo -e "\033[1;34mThe installation process will take about 5 minutes.\033[0m"

# Show progress bar for installation steps
total_steps=6
current_step=1

progress_bar $current_step $total_steps
echo -e " \033[1;34m[Step $current_step/$total_steps] Installing system dependencies...\033[0m"
sudo apt update -qq > /dev/null
sudo apt install -y -qq wget git python3 python3-venv libgl1 libglib2.0-0 > /dev/null
current_step=$((current_step + 1))

progress_bar $current_step $total_steps
echo -e " \033[1;34m[Step $current_step/$total_steps] Checking Python version...\033[0m"
if ! command -v python3.11 &> /dev/null; then
    echo -e "\033[1;34mInstalling Python 3.11...\033[0m"
    sudo add-apt-repository -y ppa:deadsnakes/ppa > /dev/null
    sudo apt update -qq > /dev/null
    sudo apt install -y -qq python3.11 > /dev/null
    python_cmd="python3.11"
else
    echo -e "\033[1;34mPython 3.11 is already installed. Using system default.\033[0m"
    python_cmd="python3"
fi
current_step=$((current_step + 1))

progress_bar $current_step $total_steps
echo -e " \033[1;34m[Step $current_step/$total_steps] Setting up 'creativeteam' user...\033[0m"
sudo adduser --disabled-password --gecos "" creativeteam > /dev/null || echo -e "\033[33mUser 'creativeteam' already exists.\033[0m"
sudo usermod -aG sudo creativeteam
current_step=$((current_step + 1))

progress_bar $current_step $total_steps
echo -e " \033[1;34m[Step $current_step/$total_steps] Cloning the repository...\033[0m"
git clone https://github.com/interactjoy/private.git /notebooks/private > /dev/null 2>&1 || echo -e "\033[33mRepository already cloned.\033[0m"
sudo chown -R creativeteam:creativeteam /notebooks/private
current_step=$((current_step + 1))

progress_bar $current_step $total_steps
echo -e " \033[1;34m[Step $current_step/$total_steps] Setting up Python environment...\033[0m"
rm -rf /notebooks/private/venv
su - creativeteam -c "$python_cmd -m venv /notebooks/private/venv"
current_step=$((current_step + 1))

progress_bar $current_step $total_steps
echo -e " \033[1;34m[Step $current_step/$total_steps] Installing Python dependencies...\033[0m"
su - creativeteam -c "/notebooks/private/venv/bin/python -m pip install -r /notebooks/private/requirements.txt > /dev/null"
current_step=$((current_step + 1))

progress_bar $current_step $total_steps
echo -e " \033[1;34m[Step $current_step/$total_steps] Starting Stable Diffusion Workplace...\033[0m"
su - creativeteam -c "cd /notebooks/private && bash webui.sh"

# Final completion message
echo -e "\n\033[1;32mInstallation complete. Your Stable Diffusion Workplace is ready!\033[0m"

# Display the Gradio link in big green text and open it in the default browser
gradio_link="http://localhost:7860"
echo -e "\n\033[1;32mYour Stable Diffusion Workplace is available at: \033[1;4m\033[1;32m$gradio_link\033[0m\033[1;32m (clickable)\033[0m"
x-www-browser "$gradio_link" &
