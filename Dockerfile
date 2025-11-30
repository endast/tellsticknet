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

COPY --chown=tellstick:tellstick pyproject.toml uv.lock README.md ./
COPY --chown=tellstick:tellstick tellsticknet ./tellsticknet

RUN uv sync --frozen --no-dev \
    && uv pip install --no-cache coloredlogs libnacl

ENTRYPOINT ["dumb-init", "--"]
CMD ["python3", "-m", "tellsticknet", "mqtt"]
