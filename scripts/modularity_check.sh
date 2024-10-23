#!/usr/bin/env bash

mapfile -t APPS < <(ls apps)

# some apps fails when used as standalone, they should be fixed and removed from here
# no new app should be added to this list
SKIP=(admin calls emr firebase mailers membership payouts specialist_profile triage visits_scheduling)

for APP in "${APPS[@]}"
do
  if [[ ! "${SKIP[*]}" =~ $APP ]];
  then
    echo "Checking $APP:"

    cd "apps/$APP" || exit
    mix test || exit

    echo ""
    cd ../..
  fi
done
