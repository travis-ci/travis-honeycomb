#!/bin/bash

# process management inspired by ryandotsmith/nginx-buildpack
psmgr=/tmp/travis-honeycomb-wait
rm -f $psmgr
mkfifo $psmgr

(
  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG papertrail --group "04 - EC2 Workers" 'program:travis-worker' -f -j | jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | honeytail --writekey=$HONEYCOMB_WRITEKEY --dataset='worker' --parser=keyval --keyval.timefield=time --keyval.filter_regex='time=' --file=- --add_field site=org --add_field infra=ec2 --samplerate 10 --dynsampling level --dynsampling repository
  echo 'org-ec2' >$psmgr
) &

(
  PAPERTRAIL_API_TOKEN=$PAPERTRAIL_API_TOKEN_ORG papertrail --group "05 - GCE Workers" 'program:travis-worker' -f -j | jq -cr '.events[]|"hostname=" + .hostname + " " + .message' | honeytail --writekey=$HONEYCOMB_WRITEKEY --dataset='worker' --parser=keyval --keyval.timefield=time --keyval.filter_regex='time=' --file=- --add_field site=org --add_field infra=gce --samplerate 10 --dynsampling level --dynsampling repository
  echo 'org-gce' >$psmgr
) &

read exit_process <$psmgr
echo "at=exit process=$exit_process"
exit 1
