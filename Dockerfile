ARG JAVA_VERSION=8
FROM openjdk:${JAVA_VERSION}-jre-alpine

# Spark
# e.g. 2.3.2
ARG SPARK_VERSION=
ARG HADOOP_VERSION=2.7

RUN apk add --no-cache curl
RUN curl -L https://www.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -O

ENV SPARK_NAME=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV SPARK_DIR /opt/${SPARK_NAME}
ENV SPARK_HOME /usr/local/spark

RUN mkdir /opt
RUN tar zxf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt

RUN apk add --no-cache bash
RUN ln -s ${SPARK_DIR} ${SPARK_HOME}

RUN apk add --no-cache python3
RUN ln -s /usr/bin/python3 /usr/bin/python
ENV PATH "${PATH}:${SPARK_HOME}/bin"

ENV SPARK_OPTS "--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info"

# Jupyter
RUN ln -s /usr/bin/pip3 /usr/bin/pip
RUN apk add --no-cache g++ python3-dev musl-dev
RUN python -m pip install --no-cache-dir jupyter

# Toree
RUN python -m pip install --no-cache-dir toree
RUN jupyter toree install --spark_home=${SPARK_HOME}

# PySpark
# `ls ${SPARK_HOME}/python/lib/py4j* | sed -E 's/.+(py4j-.+)/\1/'` to get the py4j source zip file
ENV PYTHONPATH "${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip"

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root"]
