#!/usr/bin/env bash
set -e

export USER="${USER:-jupyter}"
JUPYTER_FLAGS="${JUPYTER_FLAGS:---ip=0.0.0.0}"

mkdir -p "${NOTEBOOKS_DIR}"

if [ "${USER}" != "root" ]; then
    useradd -m "${USER}"
fi

# Generate default configuration if not exist with changes
gosu "${USER}" bash -c '
    JUPYTER_CONFIG="${HOME}/.jupyter/jupyter_notebook_config.py" && \
    if [ ! -f "${JUPYTER_CONFIG}" ]; then
        jupyter notebook --generate-config
        echo -e "import os\n\n$(cat ${JUPYTER_CONFIG})" > "${JUPYTER_CONFIG}"
        sed -i -E "s/#c.NotebookApp.notebook_dir.+/c.NotebookApp.notebook_dir = os.environ[\"NOTEBOOKS_DIR\"]/" "${JUPYTER_CONFIG}"
    fi
'

chown "${USER}:${USER}" "${NOTEBOOKS_DIR}"
exec gosu "${USER}" jupyter notebook ${JUPYTER_FLAGS}
