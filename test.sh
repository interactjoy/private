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

# Update system and install dependencies
echo -e "\033[34mWelcome to your Interact Joy Stable Diffusion Workplace. Use the Public Gradio Link at the end of the process to access your Stable Diffusion Workplace in your browser.\033[0m"
echo -e "\033[34mThe installation process will take about 5 minutes.\033[0m"

# Show progress bar for installation steps
echo -e "\033[34m[1/6] Installing system dependencies...\033[0m"
sudo apt update -qq > /dev/null
sudo apt install -y -qq wget git python3 python3-venv libgl1 libglib2.0-0 > /dev/null

# Check if Python 3.11 is required (only if system doesn't have it)
echo -e "\033[34m[2/6] Checking Python version...\033[0m"
if ! command -v python3.11 &> /dev/null; then
    echo -e "\033[34m[3/6] Installing Python 3.11...\033[0m"
    sudo add-apt-repository -y ppa:deadsnakes/ppa > /dev/null
    sudo apt update -qq > /dev/null
    sudo apt install -y -qq python3.11 > /dev/null
    python_cmd="python3.11"
else
    echo "Python 3.11 is already installed. Using system default."
    python_cmd="python3"
fi

# Create 'creativeteam' user and add to sudo group
echo -e "\033[34m[4/6] Setting up 'creativeteam' user...\033[0m"
sudo adduser --disabled-password --gecos "" creativeteam > /dev/null || echo "User 'creativeteam' already exists."
sudo usermod -aG sudo creativeteam

# Clone the 'interactjoy/private' repository (if not already cloned)
echo -e "\033[34m[5/6] Cloning the repository...\033[0m"
git clone https://github.com/interactjoy/private.git /notebooks/private > /dev/null 2>&1 || echo "Repository already cloned."

# Ensure proper ownership of the repository and all files
sudo chown -R creativeteam:creativeteam /notebooks/private

# Switch to the cloned directory
cd /notebooks/private

# Mark the repository as a safe directory for Git to avoid dubious ownership error
su - creativeteam -c "git config --global --add safe.directory /notebooks/private"

# Ensure the venv directory doesn't exist and recreate it
echo -e "\033[34m[6/6] Setting up Python environment...\033[0m"
rm -rf /notebooks/private/venv
su - creativeteam -c "$python_cmd -m venv /notebooks/private/venv"

# Install required Python dependencies
echo "Installing Python dependencies..."
su - creativeteam -c "/notebooks/private/venv/bin/python -m pip install -r /notebooks/private/requirements.txt > /dev/null"

# Run the program (webui.sh) as 'creativeteam' user
echo "Starting Stable Diffusion Workplace..."
su - creativeteam -c "cd /notebooks/private && bash webui.sh"
