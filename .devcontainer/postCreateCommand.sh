#!/bin/bash
set -e

echo "Running postCreateCommand.sh for InvenTree Plugin AI Toolkit..."

# Avoiding Dubious Ownership in Dev Containers for setup commands that use git
git config --global --add safe.directory /workspace

# Create venv in InvenTree reference
python3 -m venv /workspace/reference/inventree-source/dev/venv --system-site-packages --upgrade-deps
. /workspace/reference/inventree-source/dev/venv/bin/activate

# Remove existing gitconfig created by "Avoiding Dubious Ownership" step
# so that it gets copied from host to the container to have your global
# git config in container
rm -f /home/vscode/.gitconfig

# Fix issue related to CFFI version mismatch
pip uninstall cffi -y
sudo apt remove --purge -y python3-cffi
pip install --no-cache-dir --force-reinstall --ignore-installed cffi

# Upgrade pip
python3 -m pip install --upgrade pip

# Ensure the correct invoke is available
pip3 install --ignore-installed --upgrade invoke Pillow

# Install base level packages from InvenTree reference
cd /workspace/reference/inventree-source
pip3 install -Ur contrib/container/requirements.txt --require-hashes

# Run initial InvenTree server setup
invoke update -s

# Configure dev environment
invoke dev.setup-dev

# Install required frontend packages
invoke int.frontend-install

echo "Devcontainer setup complete. InvenTree is ready at http://localhost:8000"
