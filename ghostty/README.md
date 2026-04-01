# Ghostty Configs

This folder stores Ghostty config snippets that are intended to be included from your main Ghostty config.

The main Ghostty config is usually at:

- `~/.config/ghostty/config`

To add these in there:

```conf
config-file = ../../.dotfiles/ghostty/shared.conf
# For optional includes (no error if missing):
config-file = ?../../.dotfiles/ghostty/shared.conf
```

A relative path is recommended to avoid hard-coding the home directory path.
