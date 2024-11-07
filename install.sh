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
echo "Welcome to your Interact Joy Stable Diffusion Workplace. Use the Public Gradio Link at the end of the process to access your Stable Diffusion Workplace in your browser."
echo "The installation process will take about 5 minutes."
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

# Clone the 'interactjoy/private' repository
echo "Checking all files, ignore fatal error..."
git clone https://github.com/interactjoy/private.git /notebooks/private || echo "Ignoring Error, proceeding to install requirements."

# Switch to the cloned directory
cd /notebooks/private

# Set up a Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install required Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Switch to 'creativeteam' user and run the webui.sh script
echo "Running the program (webui.sh) as 'creativeteam' user..."
su - creativeteam -c "cd /notebooks/private && bash webui.sh"