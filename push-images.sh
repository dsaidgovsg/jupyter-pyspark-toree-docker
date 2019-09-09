#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME=${IMAGE_NAME:-jupyter-pyspark-toree}

HIVE_TAG_SUFFIX="$(if [ "${WITH_HIVE}" = "true" ]; then echo _hive; fi)"
TAG_NAME="${JUPYTER_VERSION}_spark-${SPARK_VERSION}_scala-${SCALA_VERSION}_hadoop-${HADOOP_VERSION}_python-${PYTHON_VERSION}${HIVE_TAG_SUFFIX}_debian"

docker login -u="${DOCKER_USERNAME}" -p="${DOCKER_PASSWORD}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG_NAME}"
