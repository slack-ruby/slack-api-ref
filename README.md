Slack API Reference
-------------------

[![validate](https://github.com/slack-ruby/slack-api-ref/actions/workflows/validate.yml/badge.svg)](https://github.com/slack-ruby/slack-api-ref/actions/workflows/validate.yml)
[![update](https://github.com/slack-ruby/slack-api-ref/actions/workflows/update.yml/badge.svg)](https://github.com/slack-ruby/slack-api-ref/actions/workflows/update.yml)

![](slack.png)

This is a maintained, machine-readable version of the Slack API Docs, generated by scraping [api.slack.com](https://api.slack.com).

* [groups](groups): Web API groups.
* [methods](methods): Web API methods, organized in groups.
* [events](events): RealTime API events.

[Known undocumented methods and groups](https://github.com/ErikKalkoken/slackApiDoc) have been added manually.

* [methods](methods/undocumented): Undocumented methods.
* [groups](groups/undocumented): Undocumented groups.

### It needs an update!

Usually our [cron](CRON.md) will take care of that within 24 hours.

If you need to trigger an update right now, run `rake api:update`. To check if all specifications have a valid format, run `rake api:validate`. If all looks good, please create a pull request. See [CONTRIBUTING](CONTRIBUTING.md) for details.

### Usage

The reference is used by the following client projects to generate API client code.

* [slack-ruby-client](https://github.com/dblock/slack-ruby-client): Slack Ruby Client

### Slack

This project is not affiliated with the [company that makes Slack](https://slack.com). We began by forking JSON schema files from [slackhq/slack-api-docs](https://github.com/slackhq/slack-api-docs), then updating the schema from the documentation at [api.slack.com](https://api.slack.com) to, finally, relying on a scraper. Undocumented methods have been added in November 2017 and are maintained manually.

### Copyright & License

Copyright (c) 2015-2017, Daniel Doubrovkine and [Contributors](CHANGELOG.md).

This project is licensed under the [MIT License](LICENSE.md).
