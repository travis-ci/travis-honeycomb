#!/bin/bash

# process management inspired by ryandotsmith/nginx-buildpack
psmgr=/tmp/travis-honeycomb-wait
rm -f $psmgr
mkfifo $psmgr

if [ -z ${ENV+x} ]; then
  echo "please set ENV to 'staging' or 'production'"
  echo "we need it to choose the program filter on macstadium"
  exit 1
fi

HONEYCOMB_DATASET='worker'
PAPERTRAIL_GROUP_SUFFIX=''
if [[ "$ENV" = 'staging' ]]; then
  HONEYCOMB_DATASET='worker-staging'
  PAPERTRAIL_GROUP_SUFFIX=' (Staging)'
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
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      --samplerate 10 \
      --dynsampling level \
      --dynsampling repository

  echo "$SITE-$INFRA" >$psmgr
) &

sleep 1

(
  SITE=org
  INFRA=gce
  PAPERTRAIL_GROUP="05 - GCE Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

  papertrail \
      --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
      "program:$PAPERTRAIL_PROGRAM" \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      --samplerate 10 \
      --dynsampling level \
      --dynsampling repository

  echo "$SITE-$INFRA" >$psmgr
) &

sleep 1

(
  SITE=org
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"
  PAPERTRAIL_PROGRAM="travis-worker-$ENV"
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG

  papertrail \
      --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
      "program:$PAPERTRAIL_PROGRAM" \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      --samplerate 10 \
      --dynsampling level \
      --dynsampling repository

  echo "$SITE-$INFRA" >$psmgr
) &

sleep 1

(
  SITE=com
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

  papertrail \
      --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
      "program:$PAPERTRAIL_PROGRAM" \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      --samplerate 10 \
      --dynsampling level \
      --dynsampling repository

  echo "$SITE-$INFRA" >$psmgr
) &

sleep 1

(
  SITE=com
  INFRA=gce
  PAPERTRAIL_GROUP="05 - GCE Workers"
  PAPERTRAIL_PROGRAM='travis-worker'
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

  papertrail \
      --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
      "program:$PAPERTRAIL_PROGRAM" \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      --samplerate 10 \
      --dynsampling level \
      --dynsampling repository

  echo "$SITE-$INFRA" >$psmgr
) &

sleep 1

(
  SITE=com
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"
  PAPERTRAIL_PROGRAM="travis-worker-$ENV"
  export PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM

  papertrail \
      --group "${PAPERTRAIL_GROUP}${PAPERTRAIL_GROUP_SUFFIX}" \
      "program:$PAPERTRAIL_PROGRAM" \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset="$HONEYCOMB_DATASET" \
      --parser=keyval \
      --keyval.timefield=time \
      --keyval.filter_regex='time=' \
      --file=- \
      --add_field site=$SITE \
      --add_field infra=$INFRA \
      --samplerate 10 \
      --dynsampling level \
      --dynsampling repository

  echo "$SITE-$INFRA" >$psmgr
) &

read exit_process <$psmgr
echo "at=exit process=$exit_process"
exit 1
