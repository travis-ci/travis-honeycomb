#!/bin/bash

# process management inspired by ryandotsmith/nginx-buildpack
psmgr=/tmp/travis-honeycomb-wait
rm -f $psmgr
mkfifo $psmgr

(
  SITE=org
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"

  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG papertrail \
      --group "$PAPERTRAIL_GROUP" \
      'program:travis-worker' \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset='worker' \
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

(
  SITE=org
  INFRA=gce
  PAPERTRAIL_GROUP="05 - GCE Workers"

  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG papertrail \
      --group "$PAPERTRAIL_GROUP" \
      'program:travis-worker' \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset='worker' \
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

(
  SITE=org
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"

  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG papertrail \
      --group "$PAPERTRAIL_GROUP" \
      'program:travis-worker' \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset='worker' \
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

(
  SITE=com
  INFRA=ec2
  PAPERTRAIL_GROUP="04 - EC2 Workers"

  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM papertrail \
      --group "$PAPERTRAIL_GROUP" \
      'program:travis-worker' \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset='worker' \
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

(
  SITE=com
  INFRA=gce
  PAPERTRAIL_GROUP="05 - GCE Workers"

  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM papertrail \
      --group "$PAPERTRAIL_GROUP" \
      'program:travis-worker' \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset='worker' \
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

(
  SITE=com
  INFRA=macstadium
  PAPERTRAIL_GROUP="08 - MacStadium"

  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_COM papertrail \
      --group "$PAPERTRAIL_GROUP" \
      'program:travis-worker' \
      -f -j | \
    jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | \
    honeytail \
      --writekey=$HONEYCOMB_WRITEKEY \
      --dataset='worker' \
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
