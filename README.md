# Example Project

This project serves as a template for creating Python projects in the Dense
Analysis preferred manner. See Development steps below for initial setup, and
after boostraping a new project edit project files as you see fit to start off
your Python project.

## Development

Set up virtualenv initially for local development like so:

```sh
pyenv install
python -m pip install uv
uv sync
```

If you are creating a new project, you can quickly set it up with the
convenience script, which will delete itself after it's run.

```sh
./bootstrap-project.sh new_project_name
```

You can check the project for errors like so:

```sh
# Run the linter and autofix warnings/errors.
uv run ruff check --fix
# Run the type checker to spot typing issues.
uv run pyright
# Run unit and integration tests.
uv run pytest
```

To add dependencies, use one of the following commands:

```sh
uv add some_package
uv add --dev some_package
```

You can run the project with `docker compose` like so:

```sh
docker compose up
```

You can test the docker image like so:

```sh
docker build --no-cache -t example_project:latest .
docker run -it --rm example_project:latest
```
