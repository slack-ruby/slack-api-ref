#!/bin/bash

# Immediately exit on error
set -e
set -o pipefail

bundle exec rake api:update
bundle exec rake api:validate

gh_token="${GH_TOKEN-}"

if [ -z "$gh_token" ]
then
  echo "GH_TOKEN is not set. Cannot proceed." >&2
  exit 1
fi

git config --global user.name "Slack API Ref Buildbot"
git config --global user.email "buildbot@slack-api-ref.com"
git add .
if ! git diff --quiet --staged
  then
		git commit -m "Updated from Slack docs, `date +%Y/%m/%d`."
		git push "https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" HEAD:master
 else
   echo "Nothing has changed! I hope that's what you expected." >&2
fi
