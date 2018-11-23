#!/usr/bin/env sh
USER="${USER:-jupyter}"
JUPYTER_FLAGS="${JUPYTER_FLAGS:---ip=0.0.0.0}"

mkdir -p "${NOTEBOOKS_DIR}"

if [ "${USER}" != "root" ]; then
    adduser -D ${USER}
fi

chown "${USER}:${USER}" ${NOTEBOOKS_DIR}
exec gosu "${USER}" jupyter notebook ${JUPYTER_FLAGS}
