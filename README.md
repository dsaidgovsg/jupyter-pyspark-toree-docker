# Jupyter Spark Toree Notebook Docker Builder

Dockerfile setup to install Jupyter with PySpark and Toree Kernel for Spark
development.

The base image used also contains some other useful Cloud SDK JARs, details can
be found in the repo <https://github.com/guangie88/spark-custom-addons>.

## How to Apply Travis Template

For Linux user, you can download Tera CLI v0.2 at
<https://github.com/guangie88/tera-cli/releases> and place it in `PATH`.

Otherwise, you will need `cargo`, which can be installed via
[rustup](https://rustup.rs/).

Once `cargo` is installed, simply run `cargo install tera-cli --version=^0.2.0`.
