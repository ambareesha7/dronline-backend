#!/usr/bin/env bash
set -e

SRC_DIR=messages
EXT_DIR=extensions
DST_DIR=build-elixir

mkdir -p ${DST_DIR}
protoc -I=${EXT_DIR} -I=${SRC_DIR} --elixir_out=${DST_DIR} ${SRC_DIR}/*.proto
