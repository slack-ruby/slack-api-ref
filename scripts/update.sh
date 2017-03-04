#!/bin/bash

bundle exec rake api:update && \
bundle exec rake api:validate && \
git config --global user.name "Slack API Ref Buildbot" && \
git config --global user.email "buildbot@slack-api-ref.com" && \
git add . && \
git commit -m "Automatic update at `date`" && \
git push origin master
