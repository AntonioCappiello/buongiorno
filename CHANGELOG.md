# Changelog

All notable changes to this skill are listed here. Versions follow
[Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-10-15

First public release.

### Added
- Two-round interview: places, languages, work, hobbies, limits, delivery, and optional
  extras (money and admin, events calendar, tone, extra recipients).
- Source guide with Google News RSS recipes for small towns, free data APIs (weather,
  pollen, air quality, exchange rates, earthquakes, official warnings) and known problems.
- `check_feeds.py`: tests feeds for status, item count and freshness, and prints recent
  titles for the smallest places.
- Prompt template with a fixed email design, honesty rules, a daylight-saving-proof timing
  gate, optional memory in a private git repo, and run stats.
- Delivery guides for Telegram, Resend, Postmark, SendGrid, Mailgun, Gmail, Slack and Discord.
- Saves each newsletter's prompt in a private local git folder (and the memory repo if
  used), so every change has a history.
- A flow for changing a newsletter later: start from the live routine, test new sources,
  make the smallest edit, save, test, and undo from history.

### Security
- Security rules in every generated prompt: fetched content is untrusted data, a host
  allowlist, a fixed recipient, no printing of secrets or environment dumps, no
  force-pushes.
- Secrets live in a dedicated cloud environment, never "Default".
- Setup treats feed titles and pages as data, and tells users to revoke any key pasted
  into the chat. Extra recipients must have agreed, and their copy leaves out personal
  actions and money items.
- Each release lists the SHA-256 checksum of `buongiorno.skill`.
- Git tokens are passed as a request header and are limited to one private repository;
  the header is rebuilt in the same command as the push.
- Article lookups for headline-only items use WebFetch on the outlet's own site only.
- `check_feeds.py` only fetches public http(s) addresses (also after redirects), caps
  response size, enforces an overall time limit per feed, and cleans untrusted titles
  before printing them.

[1.0.0]: https://github.com/AntonioCappiello/buongiorno/releases/tag/v1.0.0
