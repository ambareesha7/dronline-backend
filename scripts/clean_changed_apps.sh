#!/usr/bin/env bash

mapfile -t CHANGED_APPS < <(git diff origin/master --name-status | grep "apps/" | cut -d'/' -f2 | sort -u)

for CHANGED_APP in "${CHANGED_APPS[@]}"
do
  rm -rf "_build/dev/lib/${CHANGED_APP}"
  echo "Cleaned _build/dev/lib/${CHANGED_APP}"

  rm -rf "_build/test/lib/${CHANGED_APP}"
  echo "Cleaned _build/test/lib/${CHANGED_APP}"
done
