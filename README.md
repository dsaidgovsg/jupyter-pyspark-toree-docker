# Jupyter Spark Toree Notebook Docker Builder

Dockerfile setup to install Jupyter with PySpark and Toree Kernel for Spark
development.

Contains the following Jupyter kernels:

- \>= Python 2.7
- \>= Python 3.5
- \>= Toree 0.3

## Example build and run commands

```bash
SPARK_VERSION=2.4.0

# Build
docker build . \
    --build-arg SPARK_VERSION=${SPARK_VERSION} \
    -t guangie88/jupyter-pyspark-toree:spark-${SPARK_VERSION}

# Run
docker run --rm -it \
    -p 8888:8888 \
    guangie88/jupyter-pyspark-toree:spark-${SPARK_VERSION}
```
