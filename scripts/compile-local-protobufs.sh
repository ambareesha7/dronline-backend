#!/usr/bin/env bash

protoc \
  -I apps/proto/proto_submodule/extensions -I apps/proto/proto_submodule/messages \
  --elixir_out=./apps/proto/lib/pb apps/proto/proto_submodule/messages/*.proto
