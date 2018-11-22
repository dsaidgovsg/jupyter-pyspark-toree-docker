# Jupyter Spark Toree Notebook Docker Builder

Dockerfile setup to install Jupyter with PySpark and Toree Kernel for Spark development

## Example build and run commands

```bash
docker build . --build-arg SPARK_VERSION=2.3.2 -t jupyter-spark-notebook:2.3.2
docker run --rm -it -p 8888:8888 jupyter-spark-notebook:2.3.2
```
