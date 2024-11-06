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

# Step 1: Clone the Github Repo
echo "Cloning the GitHub repository..."
if [ ! -d "creative" ]; then
    git clone https://github.com/interactjoy/private.git
else
    echo "Repository already cloned, skipping..."
fi

# Step 2: Install MiniConda
echo "Downloading and installing Miniconda..."
if [ ! -d "/notebooks/Miniconda" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /notebooks/Miniconda
    export PATH="/notebooks/Miniconda/bin:$PATH"
    source ~/.bashrc  # First source to apply changes
else
    echo "Miniconda already installed, skipping..."
fi

# Step 3: Create Conda environment
echo "Creating Conda environment..."
if conda info --envs | grep -q "creativeenv"; then
    echo "Conda environment 'creativeenv' already exists, skipping..."
else
    conda create --name creativeenv python=3.10.6 -y
fi

# Step 4: Initialize and activate Conda environment
echo "Initializing and activating Conda environment..."
conda init

# Source .bashrc again after conda init to ensure all settings take effect
source ~/.bashrc
sleep 5  # Delay for 5 seconds to ensure all changes are loaded

# Activate the environment
conda activate creativeenv

# Step 5: Navigate to the project folder
echo "Navigating to the project folder..."
cd /notebooks/creative

# Step 6: Install Dependencies
echo "Installing dependencies..."
sudo apt install -y wget git python3 python3-venv libgl1 libglib2.0-0

# Step 7: Run Program
echo "Launching the program..."
if [ -f "webui.sh" ]; then
    bash webui.sh
else
    echo "Program script webui.sh not found. Please check the installation."
fi

echo "Installation and setup complete!"
