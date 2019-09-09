# Debian based
ARG FROM_DOCKER_IMAGE="guangie88/spark-custom-addons"
ARG FROM_DOCKER_TAG=

FROM ${FROM_DOCKER_IMAGE}:${FROM_DOCKER_TAG}
ARG JUPYTER_VERSION=
ARG PY4J_SRC=
ENV GOSU_VERSION "1.11"

RUN set -euo && \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Necessary deps
        g++ libc6-dev \
        # Build-time only deps
        wget; \
    #
    # Python installation
    #
    python -m pip install ipykernel; \
    #
    # Jupyter
    #
    python -m pip install --no-cache-dir "jupyter==${JUPYTER_VERSION}" "tornado<6" toree; \
    jupyter --version; \
    # Set the right Python version for Spark worker under PySpark
    apt-get install -y --no-install-recommends jq; \
    ## Python 2 prints version to stderr
    PYTHON_MAJOR_VERSION="$(python --version 2>&1 | grep -oE '[[:digit:]]\.[[:digit:]]\.[[:digit:]]' | cut -d '.' -f1)"; \
    PYTHON_KERNEL_CONF="/usr/local/share/jupyter/kernels/python${PYTHON_MAJOR_VERSION}/kernel.json"; \
    cat "${PYTHON_KERNEL_CONF}" \
        | jq --argjson env '{ "PYSPARK_PYTHON": "python" }' '. + {env: $env}' \
        > "${PYTHON_KERNEL_CONF}.tmp"; \
    mv "${PYTHON_KERNEL_CONF}.tmp" "${PYTHON_KERNEL_CONF}"; \
    apt-get remove -y jq; \
    #
    # Toree
    #
    jupyter toree install --spark_home=${SPARK_HOME}; \
    #
    # gosu installation (https://github.com/tianon/gosu#installation)
    #
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$dpkgArch.asc"; \
    # Verify the signature
    GNUPGHOME="$(mktemp -d)"; \
    apt-get install -y --no-install-recommends gnupg2 dirmngr; \
    # Skip the verification step for now, the keyserver is very buggy
    # For flaky keyservers, consider https://github.com/tianon/pgp-happy-eyeballs, ala https://github.com/docker-library/php/pull/666
    # count=0; \
    # until (gpg2 --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4) || ((count++ >= 10)); do \
        # echo "Cannot contact keyserver, trying again..." \
    # done; \
    # gpg2 --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    # command -v gpgconf && gpgconf --kill all || :; \
    rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc; \
    # Clean up fetch dependencies
    chmod +x /usr/local/bin/gosu; \
    # Verify that the binary works
    gosu --version; \
    gosu nobody true; \
    apt-get remove -y gnupg2 dirmngr; \
    #
    # Remove unnecessary build-time only dependencies
    #
    apt-get remove -y wget; \
    rm -rf /var/lib/apt/lists/*

# `ls ${SPARK_HOME}/python/lib/py4j* | sed -E "s/.+(py4j-.+)/\1/" | tr -d "\n"` to get the py4j source zip file
ENV PYTHONPATH "${SPARK_HOME}/python:${SPARK_HOME}/python/lib/${PY4J_SRC}"
ENV NOTEBOOKS_DIR "/notebooks/"

COPY run.sh /
EXPOSE 8888
CMD ["./run.sh"]
