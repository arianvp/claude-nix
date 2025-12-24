# Claude-Nix Examples

This directory contains two approaches to managing Claude Code configuration with Nix.

## Two Patterns

### 1. [Plain Pattern](./plain/) - Direct `.claude` Directory

The simplest approach: build a `.claude` directory directly.

```bash
nix build .#claude-config --profile .claude
```

**When to use:**
- Project-specific configurations
- Simple, straightforward setup
- You don't need to share config across projects

**Key features:**
- Uses `mkClaude` function
- Still uses helper functions (`mkSkill`, `mkCommand`, `mkAgent`)
- Direct control over the directory structure
- No marketplace abstraction overhead

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
| Setup | `nix build .#claude-config --profile .claude` | `nix build .#claude-code --profile .claude` |
| Sharing | Manual | Built-in |
| Dynamic enable/disable | No | Yes |
| Versioning | Manual | Built-in |
| Best for | Single projects | Multi-project setups |

## Both Use the Same Building Blocks

Both patterns use the same helper functions:
- `mkSkill` - Creates a skill with frontmatter
- `mkCommand` - Creates a slash command
- `mkAgent` - Creates an agent definition

The difference is how they're organized:
- **Plain**: `mkClaude { skills = [...]; commands = [...]; }`
- **Marketplace**: `mkPlugin {...}` → `mkMarketplace {...}` → `mkClaudeCode {...}`

## Getting Started

1. **For a simple project-specific config**: Start with the [plain pattern](./plain/)
2. **For shared configs or multiple projects**: Use the [marketplace pattern](./marketplace/)
3. **Not sure?** Start with plain - you can always migrate to marketplace later!
