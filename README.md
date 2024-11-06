# Installation and Running

**Automatic Installation on Windows**

Python Dependency:
1. Install Python 3.10.6 (Newer version of Python does not support torch), checking "Add Python to PATH".
https://www.python.org/downloads/release/python-3106/

Set up conda environment with git installed:

2. conda create --name stableenv python=3.10.6

3. conda activate stableenv

4. conda install git

5. git clone https://github.com/interactjoy/private.git

6. Run webui-user.bat from Windows Explorer as normal, non-administrator, user.

**Automatic Installation on Linux**
Install the dependencies:
Paperspace start from scratch - (Debian-based):
sudo apt install wget git python3 python3-venv libgl1 libglib2.0-0
git clone https://github.com/interactjoy/private.git
Run webui.sh.
Check webui-user.sh for options.
