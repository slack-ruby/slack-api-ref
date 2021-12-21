# Travis CI cron support

This project uses a Travis CI cronjob to automatically sync with the offical Slack documentation once per day.  
To make this work, we needed to generate a personal access token with the `public_repo` permission. That's the only Github API permission that is required.
Since the token should be private, we pass it to Travis securely as an environment variable in our repository settings.
The environment variable is called `GH_TOKEN`.

# Recreating the Github token

In case the `GH_TOKEN` needs to be renewed, please follow these steps:

1. [Create a personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).
2. Go to the [`slack-api-ref` settings](https://app.travis-ci.com/slack-ruby/slack-api-ref/settings) on Travis.
2. [Add the access token](https://docs.travis-ci.com/user/environment-variables#Defining-Variables-in-Repository-Settings) as an environment variable.

Official instructions can be found [here](https://docs.travis-ci.com/user/deployment/pages/#Setting-the-GitHub-token).
