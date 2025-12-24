# Claude-Nix Examples

This directory contains two approaches to managing Claude Code configuration with Nix.

## Two Patterns

### 1. [Plain Pattern](./plain/) - Using `--plugin-dir`

The simplest approach: use Claude's native `--plugin-dir` flag.

```bash
nix run .#claude-code
```

**When to use:**
- Project-specific configurations
- Simple, straightforward setup
- You don't need to share config across projects
- You want to avoid Claude's plugin manager

**Key features:**
- Uses `mkClaude` to create a wrapper script
- Still uses `mkPlugin`, `mkSkill`, `mkCommand`, `mkAgent`
- Leverages Claude's native `--plugin-dir` flag
- No marketplace or plugin manager overhead
- Plugins stay isolated in the Nix store

### 2. [Marketplace Pattern](./marketplace/) - Plugin System

More complex: organize configs into plugins within marketplaces.

```bash
nix build .#claude-code --profile .claude
```

**When to use:**
- Sharing plugins across multiple projects
- Need versioning and distribution
- Want to enable/disable plugins dynamically
- Building a library of reusable configurations

**Key features:**
- Uses `mkPlugin`, `mkMarketplace`, `mkClaudeCode`
- Organized by publisher/owner
- Can install plugins from remote marketplaces
- Settings-based enable/disable

## Quick Comparison

| Feature | Plain | Marketplace |
|---------|-------|-------------|
| Complexity | Low | Medium |
| Setup | `nix run .#claude-code` | `nix build .#claude-code --profile .claude` |
| Plugin loading | `--plugin-dir` flags | Marketplace system |
| Sharing | Manual | Built-in |
| Dynamic enable/disable | No | Yes |
| Versioning | Manual | Built-in |
| Best for | Single projects | Multi-project setups |

## Both Use the Same Building Blocks

Both patterns use the same helper functions:
- `mkPlugin` - Creates a plugin with `.claude-plugin/plugin.json`
- `mkSkill` - Creates a skill with frontmatter
- `mkCommand` - Creates a slash command
- `mkAgent` - Creates an agent definition

The difference is how they're loaded:
- **Plain**: `mkClaude { plugins = [...] }` → Wrapper with `--plugin-dir` flags
- **Marketplace**: `mkPlugin {...}` → `mkMarketplace {...}` → `mkClaudeCode {...}` → `.claude-nix/marketplaces/`

## Getting Started

1. **For a simple project-specific config**: Start with the [plain pattern](./plain/)
2. **For shared configs or multiple projects**: Use the [marketplace pattern](./marketplace/)
3. **Not sure?** Start with plain - you can always migrate to marketplace later!
