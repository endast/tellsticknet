FROM python:3.12-slim

WORKDIR /app

RUN set -x \
&& apt-get update \
&& apt-get -y --no-install-recommends install dumb-init libsodium23 curl \
&& apt-get -y autoremove \
&& apt-get -y clean \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /tmp/* \
&& rm -rf /var/tmp/* \
&& useradd -M --home-dir /app tellstick \
  ;

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

COPY pyproject.toml uv.lock ./
COPY tellsticknet ./tellsticknet

RUN uv sync --frozen --no-dev && \
    uv pip install --system --no-cache coloredlogs libnacl \
  ;

USER tellstick

COPY . ./

ENTRYPOINT ["dumb-init", "--", "python3", "-m", "tellsticknet", "mqtt"]
