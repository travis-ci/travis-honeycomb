# worker-honeycomb

parse logs from [worker](https://github.com/travis-ci/worker) ([logrus](https://github.com/sirupsen/logrus) format) and ship them to [honeycomb](https://honeycomb.io/) via [honeytail](https://github.com/honeycombio/honeytail)!

this runs on heroku.

it uses the ruby and apt buildpacks:

```
heroku buildpacks:add heroku/ruby
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-apt
```
