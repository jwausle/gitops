#!/bin/bash

WORKING_DIR=${1:-"."}
DRY_RUN=false
if [[ $* == *--dry-run* ]] ; then
  DRY_RUN=true
fi

if [ "$WORKING_DIR" == "--dry-run" ] ; then
  WORKING_DIR="."
fi

if $DRY_RUN ; then
  find "$WORKING_DIR" -type f  | grep .bak$
else
  find "$WORKING_DIR" -type f | grep .bak$ | xargs rm
fi
