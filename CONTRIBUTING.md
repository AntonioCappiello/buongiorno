# Contributing

Thanks for helping. The most useful contributions are small and concrete.

## Good first contributions

- **A broken source.** A feed or API in `references/sources.md` that moved or stopped
  working. Open an issue with the "Broken source" template.
- **A recipe for your country.** Public broadcaster feeds, official weather warnings,
  open data portals, and Google News quirks in your language.
- **Clearer interview questions,** especially for readers who aren't technical.

## Ground rules

- Keep the security rules in `references/prompt-template.md` intact. Changes that relax
  them need a clear reason in the pull request.
- No personal data in examples. Use fictional readers and places.
- Only free sources that need no account, unless clearly marked as optional.
- Test feeds with `scripts/check_feeds.py` before adding them, and paste the output in the
  pull request.
- Add a line to `CHANGELOG.md` under an "Unreleased" heading.

## Testing a change to the skill

1. Copy `skills/buongiorno` to `~/.claude/skills/`.
2. Start a new Claude Code session and build a newsletter for a made-up reader.
3. Check that the dry-run sample still renders and that no section is empty without
   explanation.

## Releasing (maintainers)

1. Update both versions in `.claude-plugin/marketplace.json`,
   and move "Unreleased" in `CHANGELOG.md` to the new version.
2. Tag and push: `git tag v1.1.0 && git push --tags`. The release workflow builds
   `buongiorno.skill` and attaches it to the GitHub release.
