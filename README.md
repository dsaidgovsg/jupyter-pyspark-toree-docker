# Jupyter Spark Toree Notebook Docker Builder

Dockerfile setup to install Jupyter with PySpark and Toree Kernel for Spark
development.

Contains the following Jupyter kernels:

- \>= Python 2.7
- \>= Python 3.5
- \>= Toree 0.3

## Generation of `.travis.yml`

This requires `python3` and `pip`. This will allow the installation of
`jinja2-cli`.

Run the following:

```bash
python3 -m pip install --user jinja2-cli[yaml]
```

Once installed, to generate the new `.travis.yml` file, run:

```bash
./apply-vars.sh
```

As such, it is generally only necessary to update `vars.yml` to generate for
new Spark builds.
