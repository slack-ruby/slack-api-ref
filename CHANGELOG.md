Changelog
---------

Some notable infrastructure contributions below. See [commits](commits/master) for Slack API updates.

* Your contribution here.
* [#64](https://github.com/slack-ruby/slack-api-ref/pull/64): Add `arg_groups` for groups of arguments whose requirement is interdependent.
* [#64](https://github.com/slack-ruby/slack-api-ref/pull/64): Add `"format": "json"` attribute for arguments that need to be JSON strings.
* [#58](https://github.com/slack-ruby/slack-api-ref/pull/58): Set up Rubocop - [@kstole](https://github.com/kstole).
* [#55](https://github.com/slack-ruby/slack-api-ref/pull/55): Consider `Deprecated:` label in API method summary - [@kstole](https://github.com/kstole).
* Updated crawlers to use new API documentation DOM - [@chrisbloom7](https://github.com/chrisbloom7).
* Added undocumented methods - [@manuelmeurer](https://github.com/manuelmeurer).
* Modified method scraper to look for <a> tags within <table> - [@alexagranov](https://github.com/alexagranov).
* Added events - [@dblock](https://github.com/dblock).
* Organized methods into groups, added scraped group descriptions - [@dblock](https://github.com/dblock).
* Replaced manually edited docs with a rake task `api:methods:update` that parses API at https://api.slack.com - [@rusikf](https://github.com/rusikf).
* Initial fork, updated December 22, 2014 from https://github.com/slackhq/slack-api-docs - [@dblock](https://github.com/dblock).
