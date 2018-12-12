# worker-honeycomb

Parses logs (which need to be in the [logrus](https://github.com/sirupsen/logrus) format) from [worker](https://github.com/travis-ci/worker) and other related utilities and ships them to [honeycomb](https://honeycomb.io/) via [honeytail](https://github.com/honeycombio/honeytail)!

This runs on heroku. We're using separate dynos for .org and .com in order to bypass some rate limiting imposed by Papertrail. 

It uses the ruby and apt buildpacks:

```
heroku buildpacks:add heroku/ruby
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-apt
```

## Debugging

```
heroku logs -a travis-honeytail-staging --tail
```

## Deploying

You can deploy a branch to staging via the Travis `#deploys` Slack channel:

```
.deploy honeytail/your-branch-name to staging
```
