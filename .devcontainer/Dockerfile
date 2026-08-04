# Dockerfile for the InvenTree Plugin AI Toolkit devcontainer

# In contrast with the "production" image (which is based on an Alpine image)
# we use a Debian-based image for the devcontainer

FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm@sha256:e754c29c4e3ffcf6c794c1020e36a0812341d88ec9569a34704b975fa89e8848

# Toolkit workspace
ENV WORKSPACE="/workspace"

# InvenTree paths (pointing to reference submodule)
ENV INVENTREE_HOME="${WORKSPACE}/reference/inventree-source"
ENV INVENTREE_BACKEND_DIR="${INVENTREE_HOME}/src/backend"
ENV INVENTREE_DATA_DIR="/inventree-data"
ENV INVENTREE_STATIC_ROOT="${INVENTREE_DATA_DIR}/static"
ENV INVENTREE_MEDIA_ROOT="${INVENTREE_DATA_DIR}/media"
ENV INVENTREE_BACKUP_DIR="${INVENTREE_DATA_DIR}/backup"
ENV INVENTREE_PLUGIN_DIR="${WORKSPACE}/plugins"
ENV INVENTREE_CONFIG_FILE="${INVENTREE_DATA_DIR}/config.yaml"
ENV INVENTREE_SECRET_KEY_FILE="${INVENTREE_DATA_DIR}/secret_key.txt"
ENV INVENTREE_OIDC_PRIVATE_KEY_FILE="${INVENTREE_DATA_DIR}/oidc.pem"
ENV INVENTREE_PY_ENV="${INVENTREE_DATA_DIR}/venv"

# Put the venv on PATH so scripts and exec shells use it by default.
# The directory does not yet exist at image build time; it will be created
# on the named volume by postCreateCommand.sh.
ENV PATH="${INVENTREE_PY_ENV}/bin:${PATH}"

# Required for running playwright within devcontainer
ENV DISPLAY=:0
ENV LIBGL_ALWAYS_INDIRECT=1

# Install required base packages
RUN apt update && apt install -y \
   python3.11-dev python3.11-venv \
   postgresql-client \
   libldap2-dev libsasl2-dev \
   libpango1.0-0 libcairo2 \
   poppler-utils weasyprint

# Install packages required for frontend development
RUN apt install -y nodejs npm

# Update to the latest stable node version
RUN npm install -g n --ignore-scripts && n lts

# Install yarn
RUN npm install -g yarn

# Ensure node and yarn are available at the command line
RUN node --version && yarn --version

RUN yarn config set httpTimeout 600000 --home

# Data and venv live on a named volume (not the Windows bind mount).
# Ensure the mount point is owned by the vscode user so the named volume
# is initialised with writeable permissions.
RUN mkdir -p /inventree-data && chown -R vscode:vscode /inventree-data

WORKDIR /workspace
USER vscode
CMD ["sleep", "infinity"]
