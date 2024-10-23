# PREPARE RELEASE
ARG CI_COMMIT_SHORT_SHA
FROM compiled:$CI_COMMIT_SHORT_SHA as builder

ARG RELEASE_NAME

WORKDIR /app/apps/teams_web

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get update && apt-get -y install nodejs
RUN npm install --prefix ./assets
RUN npm run deploy --prefix ./assets

WORKDIR /app

RUN mix phx.digest
RUN MIX_ENV=prod mix release $RELEASE_NAME --no-compile

# FINAL IMAGE
FROM debian:bullseye-slim
ARG RELEASE_NAME

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8

RUN apt-get -y update \
    && apt-get -y install libssl1.1 openssl curl \
    && apt-get -y install --no-install-recommends locales \
    && rm -rf /var/lib/apt/lists

RUN export LANG=en_US.UTF-8 \
    && echo $LANG UTF-8 > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=$LANG

WORKDIR /app
COPY --from=builder "/app/_build/prod/rel/$RELEASE_NAME" .

ENV RELEASE_NAME $RELEASE_NAME
CMD ./bin/$RELEASE_NAME start
