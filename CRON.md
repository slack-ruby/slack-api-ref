# GitHub Actions cron support

This project uses a [GitHub Actions cronjob](https://github.com/slack-ruby/slack-api-ref/actions/workflows/update.yml) to automatically sync with the official Slack documentation once per day.

# Running manually

You can also sync manually. You may want to do this if the cronjob fails or if you need to sync prior to the scheduled cronjob time.

- Read the [contributing guide](https://github.com/slack-ruby/slack-api-ref/blob/master/CONTRIBUTING.md).
- Install dependencies.

```bash
bundle install
```

- Run the update and validate Rake tasks.
  - Be patient as the update task may take some time.

```bash
bundle exec rake api:update
bundle exec rake api:validate
```

- Open a pull request with the updated files.
