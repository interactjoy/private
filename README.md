Installation and Running
Make sure the required dependencies are met and follow the instructions available for:

NVidia

**Automatic Installation on Windows**
Install Python 3.10.6 (Newer version of Python does not support torch), checking "Add Python to PATH".
Install git.
Download the repository, for example by running git clone
Run webui-user.bat from Windows Explorer as normal, non-administrator, user.

**Automatic Installation on Linux**
Install the dependencies:
# Debian-based:
sudo apt install wget git python3 python3-venv libgl1 libglib2.0-0
# Red Hat-based:
sudo dnf install wget git python3 gperftools-libs libglvnd-glx
# openSUSE-based:
sudo zypper install wget git python3 libtcmalloc4 libglvnd
# Arch-based:
sudo pacman -S wget git python3
If your system is very new, you need to install python3.11 or python3.10:

# Ubuntu 24.04
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.11

# Only for 3.11
# Then set up env variable in launch script
export python_cmd="python3.11"
# or in webui-user.sh
python_cmd="python3.11"
Navigate to the directory you would like the webui to be installed and execute the following command:
wget -q 
Or just clone the repo wherever you want:

git clone 
Run webui.sh.
Check webui-user.sh for options.

Installation on Apple Silicon
Find the instructions here.
