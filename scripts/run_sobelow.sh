#!/usr/bin/env bash

mix archive.install hex sobelow --force

mapfile -t APPS < <(ls apps)

for APP in "${APPS[@]}"
do
  echo "apps/$APP"
  MIX_ENV=test mix sobelow --root "apps/$APP" --exit Low --verbose --private --skip -i Config.CSP,Config.HTTPS,Config.CSWH || exit
done
