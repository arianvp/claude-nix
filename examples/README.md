# Claude-Nix Examples

This directory contains examples for managing Claude Code configuration with Nix.

## Plain Pattern - Using `--plugin-dir`

See the [plain example](./plain/) for the recommended approach.

The plain pattern uses Claude's native `--plugin-dir` flag to load plugins.

```bash
nix run .#claude-code
```

**When to use:**
- Project-specific configurations
- Simple, straightforward setup
- You don't need to share config across projects

**Key features:**
- Uses `mkClaude` to create a wrapper script
- Still uses `mkPlugin`, `mkSkill`, `mkCommand`, `mkAgent`
- Leverages Claude's native `--plugin-dir` flag
- Plugins stay isolated in the Nix store

## Building Blocks

The plain pattern uses these helper functions:
- `mkPlugin` - Creates a plugin with `.claude-plugin/plugin.json`
- `mkSkill` - Creates a skill with frontmatter
- `mkCommand` - Creates a slash command
- `mkAgent` - Creates an agent definition

How they're loaded:
- `mkClaude { plugins = [...] }` → Wrapper with `--plugin-dir` flags

## Getting Started

Start with the [plain pattern](./plain/) for a simple project-specific config!
