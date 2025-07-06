# AGENTS.md

This file tells automation agents how to build, test, lint and deploy this
project.

## Development

Set up virtualenv initially like so:

```sh
pyenv install
python -m pip install uv
uv sync
```

Install or update main dependencies like so:

```sh
uv add some_package
```

Install or a dev dependency like so:

```sh
uv add --dev some_package
```

Run the project file like so:

```sh
python -m example_project
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

## Docker targets

- **base**: installs `uv` and sets up virtualenv
- **dev**: adds dev dependencies for linting and IDE support
- **prod**: A distroless image for deployment to production

Build manually:

```sh
docker build -t example_project:base --target=base .
docker build -t example_project:dev  --target=dev .
docker build -t example_project:prod --target=prod --build-arg RELEASE_VERSION=0.1.0 .
```

## Conventions

- Code lives in `src/`
- Do not install with pip directly; use `uv`
- Always rebuild if Dockerfile or deps change
- Do not modify lock files without using `uv sync`
