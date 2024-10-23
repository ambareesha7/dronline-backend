# COMPILE IMAGE
ARG ELIXIR_VERSION
FROM elixir:${ELIXIR_VERSION} as builder

RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix hex.info

WORKDIR /app

ADD . .

RUN MIX_ENV=prod mix deps.clean mime --build
RUN MIX_ENV=prod mix do deps.get
RUN MIX_ENV=prod mix compile

ARG RELEASE_NAME

WORKDIR /app/apps/teams_web

RUN mix assets.deploy

WORKDIR /app/apps/web

RUN mix assets.deploy

WORKDIR /app

RUN mix phx.digest
RUN MIX_ENV=prod mix release $RELEASE_NAME --no-compile

# FINAL IMAGE
FROM debian:bookworm-slim
ARG RELEASE_NAME

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8

RUN apt-get -y update \
  && apt-get -y install libssl3 openssl curl \
  && apt-get -y install --no-install-recommends locales \
  && apt-get install -y wkhtmltopdf pdftk fonts-noto ca-certificates poppler-utils curl unzip \
  && rm -rf /var/lib/apt/lists

RUN export LANG=en_US.UTF-8 \
  && echo $LANG UTF-8 > /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=$LANG

WORKDIR /app
COPY --from=builder "/app/_build/prod/rel/$RELEASE_NAME" .

ENV RELEASE_NAME=$RELEASE_NAME
CMD ./bin/$RELEASE_NAME start
