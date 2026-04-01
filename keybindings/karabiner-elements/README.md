# Karabiner-Elements Rules

This directory contains Karabiner-Elements complex modification rule files in JSON format.

These files are meant to be linked into Karabiner-Elements at:

`~/.config/karabiner/assets/complex_modifications/`

## Link all JSON rules (wildcard)

Run this from the repository root:

```bash
mkdir -p ~/.config/karabiner/assets/complex_modifications
ln -sfn "$PWD"/keybindings/karabiner-elements/*.json ~/.config/karabiner/assets/complex_modifications/
```

After linking, open Karabiner-Elements and enable the rules from Complex Modifications.
