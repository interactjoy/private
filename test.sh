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
echo -e "\033[34mUpdating system packages...\033[0m"
sudo apt-get update -qq -o=Dpkg::Use-Pty=0 >/dev/null 2>&1

# Install dependencies with installation bar
for package in wget git python3 python3-venv libgl1 libglib2.0-0; do
    echo -e "\033[34mInstalling $package...\033[0m"
    sudo apt-get install -y -qq $package -o=Dpkg::Use-Pty=0 >/dev/null 2>&1
    echo -e "\033[32m$package installation complete.\033[0m"
done

# Check if Python 3.11 is required (only if system doesn't have it)
if ! command -v python3.11 &> /dev/null; then
    echo -e "\033[34mInstalling Python 3.11...\033[0m"
    sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1
    sudo apt-get update -qq -o=Dpkg::Use-Pty=0 >/dev/null 2>&1
    sudo apt-get install -y -qq python3.11 python3.11-venv -o=Dpkg::Use-Pty=0 >/dev/null 2>&1
    echo -e "\033[32mPython 3.11 installation complete.\033[0m"
    python_cmd="python3.11"
else
    echo "Python 3.11 is already installed. Using system default."
    python_cmd="python3"
fi

# Create 'creativeteam' user and add to sudo group
echo -e "\033[34mSetting up 'creativeteam' user...\033[0m"
sudo adduser --disabled-password --gecos "" creativeteam >/dev/null || echo "User 'creativeteam' already exists."
sudo usermod -aG sudo creativeteam

# Ensure proper ownership of the repository directory
if [ -d "/notebooks/private" ]; then
    echo -e "\033[34mEnsuring correct ownership of the repository directory...\033[0m"
    sudo chown -R creativeteam:creativeteam /notebooks/private
else
    echo -e "\033[34mCreating repository directory...\033[0m"
    sudo mkdir -p /notebooks/private
    sudo chown -R creativeteam:creativeteam /notebooks/private
fi

# Clone or update the 'interactjoy/private' repository
echo -e "\033[34mCloning or updating the repository...\033[0m"
if [ -d "/notebooks/private/.git" ]; then
    echo -e "\033[34mRepository already exists. Updating...\033[0m"
    cd /notebooks/private
    sudo -u creativeteam git fetch --all >/dev/null 2>&1
    sudo -u creativeteam git reset --hard origin/main >/dev/null 2>&1
    echo -e "\033[32mRepository update complete.\033[0m"
else
    echo -e "\033[34mCloning the repository...\033[0m"
    sudo -u creativeteam git clone -q https://github.com/interactjoy/private.git /notebooks/private
    echo -e "\033[32mRepository clone complete.\033[0m"
fi

# Ensure proper ownership of the repository and all files
echo -e "\033[34mEnsuring proper ownership of repository files...\033[0m"
sudo chown -R creativeteam:creativeteam /notebooks/private

# Switch to the cloned directory
cd /notebooks/private

# Mark the repository as a safe directory for Git to avoid dubious ownership error
echo -e "\033[34mConfiguring Git settings...\033[0m"
sudo -u creativeteam git config --global --add safe.directory /notebooks/private

# Ensure the venv directory doesn't exist and recreate it
echo -e "\033[34mSetting up Python virtual environment...\033[0m"
rm -rf /notebooks/private/venv
sudo -u creativeteam "$python_cmd" -m venv /notebooks/private/venv
echo -e "\033[32mPython virtual environment setup complete.\033[0m"

# Install required Python dependencies
echo -e "\033[34mInstalling Python dependencies...\033[0m"
sudo -u creativeteam /notebooks/private/venv/bin/python -m pip install -q -r /notebooks/private/requirements.txt >/dev/null 2>&1
echo -e "\033[32mPython dependencies installation complete.\033[0m"

# Add permission and run the extensions.sh file
echo -e "\033[34mRunning extensions setup...\033[0m"
chmod +x /notebooks/private/extensions.sh
sudo -u creativeteam bash /notebooks/private/extensions.sh >/dev/null 2>&1

echo -e "\033[32mSetup completed successfully!\033[0m"
