# COMPILE PROJECT
ARG BASE_IMAGE
FROM $BASE_IMAGE

WORKDIR /app

ADD . .

RUN MIX_ENV=prod mix deps.clean mime --build
RUN MIX_ENV=prod mix do deps.get
RUN MIX_ENV=prod mix compile
