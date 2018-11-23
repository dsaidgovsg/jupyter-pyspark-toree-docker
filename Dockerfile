ARG JAVA_VERSION=8
FROM openjdk:${JAVA_VERSION}-jre-alpine

# Spark
# e.g. 2.4.0
ARG SPARK_VERSION=
ARG HADOOP_VERSION="2.7"

ENV SPARK_NAME "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
ENV SPARK_DIR "/opt/${SPARK_NAME}"
ENV SPARK_HOME "/usr/local/spark"
ENV PATH "${PATH}:${SPARK_HOME}/bin"

# `ls ${SPARK_HOME}/python/lib/py4j* | sed -E 's/.+(py4j-.+)/\1/'` to get the py4j source zip file
ENV PYTHONPATH "${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip"
ENV NOTEBOOKS_DIR "/notebooks/"
ENV GOSU_VERSION "1.11"

RUN set -eux; \
    apk add --no-cache bash g++ musl-dev; \
    mkdir /opt; \
    \
    # Spark installation
    wget https://www.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz; \
    tar zxf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt; \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz; \
    ln -s ${SPARK_DIR} ${SPARK_HOME}

RUN set -eux; \
    # Python
    apk add --no-cache python3 python3-dev; \
    apk add --no-cache python2 python2-dev py2-pip; \
    python2 -m pip install ipykernel; \
    python2 -m ipykernel install;

RUN set -eux; \
    # Default to Python 3 executables
    rm /usr/bin/python /usr/bin/pip; \
    ln -s /usr/bin/python3 /usr/bin/python; \
    ln -s /usr/bin/pip3 /usr/bin/pip; \
    python3 --version; \
    python2 --version

RUN set -eux; \
    # Jupyter
    python3 -m pip install --no-cache-dir jupyter toree; \
    jupyter --version; \
    # Set the right Python version for Spark worker under PySpark
    apk add --no-cache jq; \
    PYTHON3_KERNEL_CONF="/usr/share/jupyter/kernels/python3/kernel.json"; \
    cat "${PYTHON3_KERNEL_CONF}" \
        | jq --argjson env '{ "PYSPARK_PYTHON": "python3", "PYSPARK_DRIVER_PYTHON": "python3" }' '. + {env: $env}' \
        > "${PYTHON3_KERNEL_CONF}.tmp"; \
    mv "${PYTHON3_KERNEL_CONF}.tmp" "${PYTHON3_KERNEL_CONF}"; \
    PYTHON2_KERNEL_CONF="/usr/share/jupyter/kernels/python2/kernel.json"; \
    cat "${PYTHON2_KERNEL_CONF}" \
        | jq --argjson env '{ "PYSPARK_PYTHON": "python2", "PYSPARK_DRIVER_PYTHON": "python2" }' '. + {env: $env}' \
        > "${PYTHON2_KERNEL_CONF}.tmp"; \
    mv "${PYTHON2_KERNEL_CONF}.tmp" "${PYTHON2_KERNEL_CONF}"; \
    apk del jq; \
    \
    # Toree
    jupyter toree install --spark_home=${SPARK_HOME}; \
    \
    # gosu for Alpine (https://github.com/tianon/gosu/blob/master/INSTALL.md#from-alpine-37)
    apk add --no-cache --virtual .gosu-deps dpkg gnupg; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$dpkgArch.asc"; \
    # Verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    # For flaky keyservers, consider https://github.com/tianon/pgp-happy-eyeballs, ala https://github.com/docker-library/php/pull/666
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    command -v gpgconf && gpgconf --kill all || :; \
    rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc; \
    # Clean up fetch dependencies
    apk del --no-network .gosu-deps; \
    chmod +x /usr/local/bin/gosu; \
    # Verify that the binary works
    gosu --version; \
    gosu nobody true

COPY run.sh /

EXPOSE 8888

CMD ["./run.sh"]
