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

# Install system dependencies
echo "Installing required system dependencies..."
# Update system
echo "Updating system packages..."
sudo apt-get update -qq -o=Dpkg::Use-Pty=0 >/dev/null 2>&1
# Install dependencies
for package in wget git python3 python3-venv libgl1 libglib2.0-0; do
    echo "Installing $package..."
    sudo apt-get install -y -qq $package -o=Dpkg::Use-Pty=0 >/dev/null 2>&1
done

# Check if Python 3.11 is required (only if system doesn't have it)
if ! command -v python3.11 &> /dev/null; then
    echo "Installing Python 3.11..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1
    sudo apt-get update -qq -o=Dpkg::Use-Pty=0 >/dev/null 2>&1
    sudo apt-get install -y -qq python3.11 python3.11-venv -o=Dpkg::Use-Pty=0 >/dev/null 2>&1
    python_cmd="python3.11"
else
    echo "Python 3.11 is already installed. Using system default."
    python_cmd="python3"
fi

# Create 'creativeteam' user and add to sudo group
echo "Setting up 'creativeteam' user..."
sudo adduser --disabled-password --gecos "" creativeteam >/dev/null || echo "User 'creativeteam' already exists."
sudo usermod -aG sudo creativeteam

# Ensure proper ownership of the repository directory
if [ -d "/notebooks/private" ]; then
    echo "Ensuring correct ownership of the repository directory..."
    sudo chown -R creativeteam:creativeteam /notebooks/private
fi

# Clone or update the 'interactjoy/private' repository
echo "Cloning or updating the repository..."
if [ -d "/notebooks/private/.git" ]; then
    echo "Repository already exists. Updating..."
    cd /notebooks/private
    sudo -u creativeteam git fetch --all >/dev/null 2>&1
    sudo -u creativeteam git reset --hard origin/main >/dev/null 2>&1
else
    echo "Cloning the repository..."
    sudo -u creativeteam git clone -q https://github.com/interactjoy/private.git /notebooks/private
fi

# Ensure proper ownership of the repository and all files
echo "Ensuring proper ownership of repository files..."
sudo chown -R creativeteam:creativeteam /notebooks/private

# Switch to the cloned directory
cd /notebooks/private

# Mark the repository as a safe directory for Git to avoid dubious ownership error
echo "Configuring Git settings..."
sudo -u creativeteam git config --global --add safe.directory /notebooks/private

# Ensure the venv directory doesn't exist and recreate it
echo "Setting up Python virtual environment..."
rm -rf /notebooks/private/venv
sudo -u creativeteam "$python_cmd" -m venv /notebooks/private/venv

# Install required Python dependencies
echo "Installing Python dependencies..."
sudo -u creativeteam /notebooks/private/venv/bin/python -m pip install -q -r /notebooks/private/requirements.txt >/dev/null 2>&1

# Add permission and run the extensions.sh file
echo "Running extensions setup..."
chmod +x /notebooks/private/extensions.sh
sudo -u creativeteam bash /notebooks/private/extensions.sh >/dev/null 2>&1

echo "Setup completed successfully!"
