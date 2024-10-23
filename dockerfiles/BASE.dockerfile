# COMPILE BASE ELIXIR IMAGE
FROM erlang:24.3.4.13

ARG ELIXIR_VERSION
ENV	LANG=C.UTF-8

RUN apt update && apt -y install curl git inotify-tools build-essential libssl1.1 wget tar unzip

RUN curl -fSL -o elixir-precompiled.zip https://repo.hex.pm/builds/elixir/v${ELIXIR_VERSION}.zip
RUN unzip -d /usr/local elixir-precompiled.zip
RUN rm elixir-precompiled.zip

RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix hex.info
