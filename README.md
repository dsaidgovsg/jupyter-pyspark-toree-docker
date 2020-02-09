# Jupyter Spark Toree Notebook Docker Builder

![CI Status](https://img.shields.io/github/workflow/status/guangie88/jupyter-pyspark-toree-docker/CI/master?label=CI&logo=github&style=for-the-badge)

Dockerfile setup to install Jupyter with PySpark and Toree Kernel for Spark
development.

The base image used also contains some other useful Cloud SDK JARs, details can
be found in the repo <https://github.com/guangie88/spark-custom-addons>.

## How to Apply Template for CI build

For Linux user, you can download Tera CLI v0.3 at
<https://github.com/guangie88/tera-cli/releases> and place it in `PATH`.

Otherwise, you will need `cargo`, which can be installed via
[rustup](https://rustup.rs/).

Once `cargo` is installed, simply run `cargo install tera-cli --version=^0.3.0`.
