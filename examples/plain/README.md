# Plain Example

This example demonstrates **direct `.claude` directory management** with Nix, without marketplace abstractions.

## What is the Plain Pattern?

The plain pattern builds a `.claude` directory structure directly:
```
.claude/
├── skills/
│   └── nix-helper.md
├── commands/
│   └── format-nix.md
└── agents/
    └── nix-analyzer.md
```

You simply run:
```bash
nix build .#claude-config --profile .claude
```

Now the `.claude` directory contains your configuration, managed by Nix!

## Advantages

- **Simpler**: No marketplace/plugin abstractions
- **Direct**: Just build files and put them where Claude expects
- **Transparent**: Easy to see what's in your `.claude` directory
- **Flexible**: Use any Nix expression to generate files

## Usage

```bash
# Build the claude config directory
nix build .#claude-config --profile .claude

# Run Claude Code (it will read from .claude/)
claude-code
```

Or use the wrapper script:
```bash
# The wrapper does both steps
nix run .#claude-code
```

## When to Use This Pattern

Use the plain pattern when:
- You want a simple, project-specific Claude configuration
- You don't need to share config across projects
- You prefer direct control over the directory structure
- You're building a one-off configuration

## Structure

The `claude-config` package uses `mkClaude` to create the directory structure:

```nix
packages.claude-config = claudeLib.mkClaude {
  skills = [
    (claudeLib.mkSkill {
      name = "my-skill";
      description = "My skill description";
      allowed-tools = [ "Bash(${pkgs.somePackage}/bin/tool)" ];
      content = "Skill instructions...";
    })
  ];
  commands = [ /* ... */ ];
  agents = [ /* ... */ ];
  mcpServers = { /* ... */ };
};
```

This gives you:
- Type-safe configuration using Nix functions
- Reusable helper functions (`mkSkill`, `mkCommand`, `mkAgent`)
- Proper frontmatter generation
- Embedded Nix store paths for tools

## See Also

- [Marketplace Example](../marketplace/) - Full marketplace pattern with plugins
- [Main flake.nix](../../flake.nix) - Library functions and both patterns
