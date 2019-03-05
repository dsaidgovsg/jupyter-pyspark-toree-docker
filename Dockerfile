# Debian based
ARG JAVA_VERSION=8
ARG SPARK_VERSION=
FROM guangie88/spark:${SPARK_VERSION}_java-${JAVA_VERSION}

ENV GOSU_VERSION "1.11"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Necessary deps
        g++ libc6-dev \
        # Build-time only deps
        wget; \
    #
    # Python 2 installation
    #
    apt-get install -y --no-install-recommends python python-dev python-pip python-setuptools; \
    python2 -m pip install ipykernel; \
    python2 -m ipykernel install; \
    python2 --version; \
    #
    # Python 3 installation (default for running Jupyter)
    #
    apt-get install -y --no-install-recommends python3 python3-dev python3-pip python3-setuptools; \
    python3 --version; \
    #
    # Jupyter
    #
    python3 -m pip install --no-cache-dir jupyter "tornado<6" toree; \
    jupyter --version; \
    # Set the right Python version for Spark worker under PySpark
    apt-get install -y --no-install-recommends jq; \
    PYTHON3_KERNEL_CONF="/usr/local/share/jupyter/kernels/python3/kernel.json"; \
    cat "${PYTHON3_KERNEL_CONF}" \
        | jq --argjson env '{ "PYSPARK_PYTHON": "python3" }' '. + {env: $env}' \
        > "${PYTHON3_KERNEL_CONF}.tmp"; \
    mv "${PYTHON3_KERNEL_CONF}.tmp" "${PYTHON3_KERNEL_CONF}"; \
    PYTHON2_KERNEL_CONF="/usr/local/share/jupyter/kernels/python2/kernel.json"; \
    cat "${PYTHON2_KERNEL_CONF}" \
        | jq --argjson env '{ "PYSPARK_PYTHON": "python2" }' '. + {env: $env}' \
        > "${PYTHON2_KERNEL_CONF}.tmp"; \
    mv "${PYTHON2_KERNEL_CONF}.tmp" "${PYTHON2_KERNEL_CONF}"; \
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

# `ls ${SPARK_HOME}/python/lib/py4j* | sed -E 's/.+(py4j-.+)/\1/'` to get the py4j source zip file
ENV PYTHONPATH "${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip"
ENV NOTEBOOKS_DIR "/notebooks/"

COPY run.sh /
EXPOSE 8888
CMD ["./run.sh"]
