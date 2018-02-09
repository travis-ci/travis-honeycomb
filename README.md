# worker-honeycomb

parsing logs from [worker](https://github.com/travis-ci/worker) ([logrus](https://github.com/sirupsen/logrus) format) and ship them to [honeycomb](https://honeycomb.io/) via [honeytail](https://github.com/honeycombio/honeytail).

## run (yolo edition)

```
papertrail --group "10 - All Workers" 'program:travis-worker' -f -j | jq -c '.events[]' | SITE=org ruby parse-logrus.rb | jq -c 'select(.message_parsed != {}) | .message_parsed + { source_ip: .source_ip, program: .program, source_name: .source_name, site: .site, infra: .infra }' | honeytail --writekey=$(heroku config:get HONEYCOMB_WRITEKEY -a travis-api-staging) --dataset='worker' --parser=json --file=- --json.timefield="time"
```
