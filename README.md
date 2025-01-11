# INSTALL SD Linux Cloud GPU

git clone https://github.com/interactjoy/private.git && \
cd /notebooks/private && \
chmod +x install.sh && \
/notebooks/private/install.sh

# START SD Linux Cloud GPU

cd /notebooks/private

chmod +x start.sh

/notebooks/private/start.sh

# DOWNLOAD LORAs
cd /notebooks/private

python loradl.py
