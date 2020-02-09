#!/usr/bin/env bash
set -euo pipefail

docker login -u="${DOCKER_USERNAME}" -p="${DOCKER_PASSWORD}"

IMAGE_NAME=${IMAGE_NAME:-jupyter-pyspark-toree}

TAG_NAME="${SELF_VERSION}_${JUPYTER_VERSION}_spark-${SPARK_VERSION}_scala-${SCALA_VERSION}_hadoop-${HADOOP_VERSION}_python-${PYTHON_VERSION}${HIVE_TAG_SUFFIX}_debian"
docker tag "${IMAGE_NAME}:${TAG_NAME}" "${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG_NAME}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG_NAME}"

ALT_TAG_NAME="${JUPYTER_VERSION}_spark-${SPARK_VERSION}_scala-${SCALA_VERSION}_hadoop-${HADOOP_VERSION}_python-${PYTHON_VERSION}${HIVE_TAG_SUFFIX}_debian"
docker tag "${IMAGE_NAME}:${TAG_NAME}" "${DOCKER_USERNAME}/${IMAGE_NAME}:${ALT_TAG_NAME}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${ALT_TAG_NAME}"
