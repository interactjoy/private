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
echo "Installing system dependencies..."
sudo apt update
sudo apt install -y wget git python3 python3-venv libgl1 libglib2.0-0

# Check if Python 3.11 is required (only if system doesn't have it)
if ! command -v python3.11 &> /dev/null; then
    echo "Installing Python 3.11 from deadsnakes PPA..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.11
    python_cmd="python3.11"
else
    echo "Python 3.11 is already installed. Using system default."
    python_cmd="python3"
fi

# Create 'creativeteam' user and add to sudo group
echo "Setting up 'creativeteam' user..."
sudo adduser --disabled-password --gecos "" creativeteam || echo "User 'creativeteam' already exists."
sudo usermod -aG sudo creativeteam

# Clone the 'interactjoy/private' repository (if not already cloned)
echo "Cloning the repository..."
git clone https://github.com/interactjoy/private.git /notebooks/private || echo "Repository already cloned."

# Ensure proper ownership of the repository and all files
sudo chown -R creativeteam:creativeteam /notebooks/private

# Switch to the cloned directory
cd /notebooks/private

# Mark the repository as a safe directory for Git to avoid dubious ownership error
su - creativeteam -c "git config --global --add safe.directory /notebooks/private"

# Ensure the venv directory doesn't exist and recreate it
rm -rf /notebooks/private/venv
su - creativeteam -c "python3 -m venv /notebooks/private/venv"

# Install required Python dependencies
echo "Installing Python dependencies..."
su - creativeteam -c "/notebooks/private/venv/bin/python -m pip install -r /notebooks/private/requirements.txt"

#Prompt User
# Set permissions for extensions.sh
if [ -f "/notebooks/private/extensions.sh" ]; then
    chmod +x /notebooks/private/extensions.sh
else
    echo -e "\e[31mError: extensions.sh not found.\e[0m"
    echo "Error: extensions.sh not found" >> "$ERROR_LOG"
fi

# Swap to 'creativeteam' user
echo "Swapping to creativeteam' user..."
su - creativeteam -c "cd /notebooks/private

# Prompt user to run extensions.sh
read -p "Do you want to run extensions.sh now? (Y/N): " run_extensions
if [[ "$run_extensions" =~ ^[Yy]$ ]]; then
    echo -e "\e[34mRunning extensions.sh...\e[0m"
    if ! bash -c "source /notebooks/private/venv/bin/activate && cd /notebooks/private && ./extensions.sh"; then
        echo -e "\e[31mError: extensions.sh failed. Please check for issues.\e[0m"
        echo "Error in extensions.sh" >> "$ERROR_LOG"
        exit 1
    else
        echo -e "\e[32mextensions.sh completed successfully.\e[0m"
    fi
else
    echo -e "\e[33mSkipping extensions.sh.\e[0m"
fi

