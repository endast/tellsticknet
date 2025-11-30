FROM python:3.12-slim AS base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        dumb-init \
        libsodium23 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

RUN useradd -m -u 1000 -s /bin/bash tellstick \
    && chown -R tellstick:tellstick /app

USER tellstick

# Copy metadata and package
COPY --chown=tellstick:tellstick pyproject.toml uv.lock README.md ./
COPY --chown=tellstick:tellstick src/tellsticknet ./src/tellsticknet

# Sync and install dependencies
RUN uv sync --frozen --no-dev \
    && uv pip install --editable . coloredlogs libnacl

ENTRYPOINT ["dumb-init", "--"]
CMD ["tellsticknet", "mqtt"]
