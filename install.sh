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

# Step 2: Install MiniConda
echo "Downloading and installing Miniconda..."
if [ ! -d "/notebooks/Miniconda" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /notebooks/Miniconda
    export PATH="/notebooks/Miniconda/bin:$PATH"
    source ~/.bashrc
else
    echo "Miniconda already installed, skipping..."
fi

echo "Initializing and activating Conda environment..."
conda init
# Step 3: Create Conda environment
echo "Creating Conda environment..."
if conda info --envs | grep -q "creativeenv"; then
    echo "Conda environment 'creativeenv' already exists, skipping..."
else
    conda create --name creativeenv python=3.10.6
fi
# Step 4: Activate Conda environment
source ~/.bashrc
conda activate creativeenv

# Step 5: Navigate to the project folder
echo "Navigating to the project folder..."
cd /notebooks/private

# Step 6: Install Dependencies
sudo apt install wget git python3 python3-venv libgl1 libglib2.0-0

# Step 7. Run Program
echo bash webui.sh
