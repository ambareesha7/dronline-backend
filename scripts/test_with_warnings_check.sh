#!/usr/bin/env bash

function error () {
  echo "CLEAN UP AFTER YOURSELF"
  exit 69
}

script --flush --quiet --return output.log --command "mix test" || exit 1

COMPILATION_WARNINGS_COUNT=$(grep -c "warning:" output.log)
if [ "$COMPILATION_WARNINGS_COUNT" -ne 0 ]
then
  error
fi

LOGGER_WARNINGS_COUNT=$(grep -c "\[warn\]" output.log)
if [ "$LOGGER_WARNINGS_COUNT" -ne 0 ]
then
  error
fi

LOGGER_ERRORS_COUNT=$(grep -c "\[error\]" output.log)
if [ "$LOGGER_ERRORS_COUNT" -ne 0 ]
then
  error
fi
