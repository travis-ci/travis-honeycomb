#!/bin/bash

# process management inspired by ryandotsmith/nginx-buildpack
psmgr=/tmp/travis-honeycomb-wait
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
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

  echo "$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
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
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

  echo "$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
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
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

  echo "$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
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
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

  echo "$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
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
    honeytail \
      --writekey="$HONEYCOMB_WRITEKEY" \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

  echo "$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
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
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      $HONEYTAIL_ARGS

  echo "$SITE-$INFRA" >$psmgr
) &

sleep $BOOT_DELAY

(
  SITE=org
  PAPERTRAIL_SYSTEM=travis-org-hub-production
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

  papertrail \
      '"run:received event: cancel"' \
      --system travis-org-hub-production \
      --delay "$PAPERTRAIL_DELAY" \
      --color=off \
      --follow | \
    honeytail \
      --dataset hub-cancellations \
      --writekey=$HONEYCOMB_WRITEKEY \
      --parser=regex \
      --regex.line_regex='Travis::Hub::Service::(?P<service>\w+)#run:received event: (?P<event>\w+) for repo=(?P<repo>\S+) id=(?P<id>\d+) user_id=(?P<user_id>\d+)' \
      --file=-
      --add_field app=hub \
      --add_field site=$SITE

  echo "org-hub-cancellations" >$psmgr
) &

read exit_process <$psmgr
echo "at=exit process=$exit_process"
exit 1
