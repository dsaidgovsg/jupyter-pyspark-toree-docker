ARG JAVA_VERSION=8
FROM openjdk:${JAVA_VERSION}-jre-alpine

# Spark
# e.g. 2.3.2
ARG SPARK_VERSION=
ARG HADOOP_VERSION=2.7

ENV SPARK_NAME=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV SPARK_DIR /opt/${SPARK_NAME}
ENV SPARK_HOME /usr/local/spark
ENV SPARK_OPTS "--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info"
ENV PATH "${PATH}:${SPARK_HOME}/bin"

# `ls ${SPARK_HOME}/python/lib/py4j* | sed -E 's/.+(py4j-.+)/\1/'` to get the py4j source zip file
ENV PYTHONPATH "${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip"

# Jupyter
RUN apk add --no-cache bash python3 g++ python3-dev musl-dev && \
    mkdir /opt && \
    wget https://www.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar zxf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    ln -s ${SPARK_DIR} ${SPARK_HOME} && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip && \
    python -m pip install --no-cache-dir jupyter toree && \
    jupyter toree install --spark_home=${SPARK_HOME}

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root"]
