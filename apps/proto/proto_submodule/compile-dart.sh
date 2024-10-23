#!/usr/bin/env bash
set -e

SRC_DIR=messages
EXT_DIR=extensions
DST_DIR=../dronline-flutter-common/lib/models

mkdir -p ${DST_DIR}
protoc -I=${EXT_DIR} -I=${SRC_DIR} --dart_out=${DST_DIR} ${SRC_DIR}/*.proto
cd ${DST_DIR}
rm -rf ./*.pbjson.dart
rm -rf ./*.pbserver.dart