# Contribution Guidelines

## Hard Rules

### Never commit sensitive data

The following must **never** appear in any commit (code, commit messages, docs, configs, or history):

- Session URLs
- Tokens, API keys, or secrets of any kind
- Personal names
- Account identifiers (usernames, emails, account IDs)
- Passwords or credentials
- Any other sensitive or personally identifiable data

If sensitive data is committed by accident, do not just remove it in a follow-up commit — the history must be rewritten and any exposed credential rotated immediately.
