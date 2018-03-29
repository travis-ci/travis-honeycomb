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
BOOT_DELAY="${BOOT_DELAY:-1}"

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

(
  APP=worker
  SITE=org
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=worker
  SITE=org
  INFRA=gce
  PAPERTRAIL_GROUP="05 - GCE Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

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
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=worker
  SITE=com
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=high-cpu-check
  SITE=org
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"
  PAPERTRAIL_PROGRAM='high-cpu-check'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=check-docker-health
  SITE=org
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"
  PAPERTRAIL_PROGRAM='check-docker-health'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=kill-old-containers
  SITE=org
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"
  PAPERTRAIL_PROGRAM='kill-old-containers'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=worker
  SITE=com
  INFRA=gce
  PAPERTRAIL_GROUP="05 - GCE Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=worker
  SITE=com
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"
  PAPERTRAIL_PROGRAM="travis-worker-$ENV"
  PAPERTRAIL_GROUP_SUFFIX=''
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

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

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP="job-board-$ENV"
  JOB_BOARD_DATASET="job-board"
  if [[ "$ENV" = 'staging' ]]; then
    JOB_BOARD_DATASET="$JOB_BOARD_DATASET-$ENV"
  fi

  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

  papertrail \
      --system "$APP" \
      --delay "$PAPERTRAIL_DELAY" \
      --follow \
      --json | \
    jq -cr '.events[]|select(.message|contains("msg="))|"dyno="+(.program|sub("app/"; ""))+" "+.message' | \
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$JOB_BOARD_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      $HONEYTAIL_ARGS

  echo "$APP" >$psmgr
) &

sleep $BOOT_DELAY

(
  APP=jupiter-brain
  SITE=com
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"
  PAPERTRAIL_PROGRAM="jupiter-brain-$ENV-$SITE"
  PAPERTRAIL_GROUP_SUFFIX=''
  JUPITER_BRAIN_DATASET="jupiter-brain"
  if [[ "$ENV" = 'staging' ]]; then
    JUPITER_BRAIN_DATASET="$JUPITER_BRAIN_DATASET-$ENV"
  fi
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

  papertrail \
      --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
      "program:$PAPERTRAIL_PROGRAM" \
      --delay "$PAPERTRAIL_DELAY" \
      --follow \
      --json | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$JUPITER_BRAIN_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field app=$APP \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

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
  JUPITER_BRAIN_DATASET="jupiter-brain"
  if [[ "$ENV" = 'staging' ]]; then
    JUPITER_BRAIN_DATASET="$JUPITER_BRAIN_DATASET-$ENV"
  fi
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

  papertrail \
      --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
      "program:$PAPERTRAIL_PROGRAM" \
      --delay "$PAPERTRAIL_DELAY" \
      --follow \
      --json | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$JUPITER_BRAIN_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field app=$APP \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

  echo "$APP-$SITE-$INFRA" >$psmgr
) &

read exit_process <$psmgr
echo "at=exit process=$exit_process"
exit 1
