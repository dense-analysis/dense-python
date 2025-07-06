# Define Python version variables
ARG PYTHON_MINOR=3.13
ARG PYTHON_FULL=3.13.4

##################
### base image ###
##################
FROM python:${PYTHON_FULL}-slim AS base
ARG PYTHON_MINOR
ARG PYTHON_FULL

# Create directories for easy cross-architecture support.
# This makes `COPY` work easily for 64-bit ARM and x86, and creates our app dir.
RUN mkdir -p \
    /lib/aarch64-linux-gnu \
    /usr/lib/aarch64-linux-gnu \
    /lib/x86_64-linux-gnu \
    /usr/lib/x86_64-linux-gnu \
    /etc/fonts \
    /usr/share/fonts/ \
    /usr/share/fontconfig/ \
    /app/.venv

# NOTE: Add a `RUN` block to install any additional packages here.

# Create a non-root user to use for `/app/.venv`.
RUN useradd --create-home appuser && chown appuser:appuser /app/.venv
WORKDIR /app

# Copy files for `uv` including README
COPY --chown=python:python pyproject.toml uv.lock README.md /app/

USER appuser

ENV PYTHONPATH="/usr/local/lib/python${PYTHON_MINOR}/site-packages:/app/.venv/lib/python${PYTHON_MINOR}/site-packages:/app/src"

# Create a real venv, install uv into it, then sync dev deps
RUN python -m venv /app/.venv \
    && /app/.venv/bin/pip install uv==0.7.15 \
    && UV_PROJECT_ENVIRONMENT=/app/.venv /app/.venv/bin/uv sync --locked --no-group dev --no-install-project

# Edit these as you desire for your Python app, and at the bottom below.
ENTRYPOINT ["/app/.venv/bin/python"]
CMD ["-m", "example_project"]

##################
### dev image  ###
##################
FROM base AS dev
ARG PYTHON_MINOR
ARG PYTHON_FULL

USER appuser

# Install development files
RUN UV_PROJECT_ENVIRONMENT=/app/.venv \
    /app/.venv/bin/uv sync --locked --no-install-project

##################
### prod image ###
##################
# NOTE: 3.13.4 is not available as distroless YET
FROM al3xos/python-distroless:${PYTHON_MINOR}.3-debian12 AS prod
ARG PYTHON_MINOR
ARG PYTHON_FULL

ARG RELEASE_VERSION
ENV RELEASE_VERSION=${RELEASE_VERSION}

# Copy basic Linux arhitecture files from the base image.
COPY --from=base /lib/aarch64-linux-gnu/ /usr/lib/aarch64-linux-gnu/
COPY --from=base /usr/lib/aarch64-linux-gnu/ /usr/lib/aarch64-linux-gnu/
COPY --from=base /lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=base /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
# Copy fonts for text rendering tools.
COPY --from=base /etc/fonts/ /etc/fonts/
COPY --from=base /usr/share/fonts/ /usr/share/fonts/
COPY --from=base /usr/share/fontconfig/ /usr/share/fontconfig/

# NOTE: You may copy binaries or other files you need here.
# COPY --from=base /usr/bin/an-executable /usr/local/bin/an-executable

# Copy the `uv` installed application.
COPY --from=base /app/.venv /app/.venv

# Set PYTHONPATH to include /usr/local, the .venv packages, and /app/src
ENV PYTHONPATH="/usr/local/lib/python${PYTHON_MINOR}/site-packages:/app/.venv/lib/python${PYTHON_MINOR}/site-packages:/app/src"

COPY --chown=monty:monty . /app

ENTRYPOINT ["/app/.venv/bin/python"]
CMD ["-m", "example_project"]
