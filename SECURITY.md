# Security policy

Buongiorno builds an agent that reads untrusted web content every day while holding a
delivery key, so security reports are taken seriously.

## Reporting a vulnerability

Please report privately through GitHub: **Security › Report a vulnerability** on this
repository. Don't open a public issue for security problems.

Useful things to include:
- what an attacker controls (a feed item, a web page, a search result...)
- what they could make the routine do (leak a key, email someone else, run a command...)
- the prompt section or file involved, and a proof of concept if you have one

You'll get a reply within a week. Fixes go into a new release, with credit in the
changelog unless you'd rather not be named.

## Scope

In scope: the skill's instructions (`SKILL.md`, `references/`), the prompt template and
its security rules, and `scripts/check_feeds.py`.

Out of scope: Claude, Claude Code and cloud routines themselves (report those to
Anthropic), and the third-party feeds, APIs and email providers the skill points to.

## Supported versions

Only the latest release gets fixes. If you built your newsletter with an older version,
compare your routine's "Security rules" block with the one in the current
`references/prompt-template.md` and update it.
