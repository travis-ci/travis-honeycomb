#!/bin/bash

# process management inspired by ryandotsmith/nginx-buildpack
psmgr=/tmp/travis-honeytail-wait
rm -f $psmgr
mkfifo $psmgr

if [ -z ${PAPERTRAIL_API_TOKEN_ORG+x} ]; then
  echo "please set PAPERTRAIL_API_TOKEN_ORG"
  exit 1
fi
if [ -z ${PAPERTRAIL_API_TOKEN_COM+x} ]; then
  echo "please set PAPERTRAIL_API_TOKEN_COM"
  exit 1
fi

ENV="${ENV:-staging}"
PAPERTRAIL_DELAY="${PAPERTRAIL_DELAY:-2}"
BOOT_DELAY="${BOOT_DELAY:-3}"
RETRY_LIMIT="${RETRY_LIMIT:-10}"

HONEYCOMB_DATASET='worker'
PAPERTRAIL_GROUP_SUFFIX=''
if [[ "$ENV" = 'staging' ]]; then
  HONEYCOMB_DATASET='worker-staging'
  PAPERTRAIL_GROUP_SUFFIX=' (Staging)'
fi

HONEYCOMB_SAMPLE_RATE="${HONEYCOMB_SAMPLE_RATE:-1}"
HONEYTAIL_ARGS=''
if [[ "$HONEYCOMB_SAMPLE_RATE" -gt 1 ]]; then
  HONEYTAIL_ARGS="--samplerate $HONEYCOMB_SAMPLE_RATE \
    --dynsampling level"
fi

export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

(
  APP=worker
  SITE=org
  INFRA=gce
  PAPERTRAIL_GROUP="05 - GCE Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  retries=0

  while [ $retries -lt $RETRY_LIMIT ]; do
    papertrail \
        --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
        "program:$PAPERTRAIL_PROGRAM" \
        --delay "$PAPERTRAIL_DELAY" \
        --follow \
        --json | \
      jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
      perl -lape 's/message repeated \d+ times: \[ (.*)\]/$1/g' | \
      honeytail \
        --writekey="$HONEYCOMB_WRITEKEY" \
        --dataset="$HONEYCOMB_DATASET" \
        --parser=keyval \
        --keyval.timefield=time \
        --keyval.filter_regex='time=' \
        --file=- \
        --add_field app=$APP \
        --add_field site=$SITE \
        --add_field infra=$INFRA \
        $HONEYTAIL_ARGS
    retries=$[$retries+1]
    sleep $BOOT_DELAY
  done
  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=worker
  SITE=org
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"
  PAPERTRAIL_PROGRAM="travis-worker-$ENV"
  PAPERTRAIL_GROUP_SUFFIX=''
  retries=0

  while [ $retries -lt $RETRY_LIMIT ]; do
    papertrail \
        --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
        "program:$PAPERTRAIL_PROGRAM" \
        --delay "$PAPERTRAIL_DELAY" \
        --follow \
        --json | \
      jq -cr '.events[]|"hostname=" + .hostname + " " + "program=" + .program + " " + .message' | \
      perl -lape 's/message repeated \d+ times: \[ (.*)\]/$1/g' | \
      honeytail \
        --writekey="$HONEYCOMB_WRITEKEY" \
        --dataset="$HONEYCOMB_DATASET" \
        --parser=keyval \
        --keyval.timefield=time \
        --keyval.filter_regex='time=' \
        --file=- \
        --add_field app=$APP \
        --add_field site=$SITE \
        --add_field infra=$INFRA \
        $HONEYTAIL_ARGS
    retries=$[$retries+1]
    sleep $BOOT_DELAY
  done
  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=jupiter-brain
  SITE=org
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"
  PAPERTRAIL_PROGRAM="jupiter-brain-$ENV-$SITE"
  PAPERTRAIL_GROUP_SUFFIX=''
  retries=0

  while [ $retries -lt $RETRY_LIMIT ]; do
    papertrail \
        --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
        "program:$PAPERTRAIL_PROGRAM" \
        --delay "$PAPERTRAIL_DELAY" \
        --follow \
        --json | \
      jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
      honeytail \
        --writekey="$HONEYCOMB_WRITEKEY" \
        --dataset="$HONEYCOMB_DATASET" \
        --parser=keyval \
        --keyval.timefield=time \
        --keyval.filter_regex='time=' \
        --file=- \
        --add_field app=$APP \
        --add_field site=$SITE \
        --add_field infra=$INFRA \
        $HONEYTAIL_ARGS
      retries=$[$retries+1]
    sleep $BOOT_DELAY
  done
  echo "$APP-$SITE-$INFRA" >$psmgr
) &

read exit_process <$psmgr
echo "at=exit process=$exit_process"
exit 1
