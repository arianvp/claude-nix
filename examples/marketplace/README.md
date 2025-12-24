# Marketplace Example

This example demonstrates the **marketplace pattern** for organizing Claude Code configuration with Nix.

## What is the Marketplace Pattern?

The marketplace pattern uses abstractions (`mkPlugin`, `mkMarketplace`) to organize skills, commands, and agents into reusable plugins that can be:
- Shared across projects
- Versioned and distributed
- Enabled/disabled dynamically
- Organized by publisher/owner

## Structure

```
marketplace
├── plugins (multiple plugins can exist)
│   ├── plugin-nix
│   └── plugin-procastinator
└── marketplace (groups plugins together)
    └── mercury-marketplace
```

## Usage

```bash
# Build and run Claude Code with marketplace configuration
nix build .#claude-code --profile .claude
./result/bin/claude-code
```

This will:
1. Build the marketplace packages
2. Link them to `.claude-nix/marketplaces/`
3. Generate settings.json with enabled plugins
4. Run Claude Code with the configuration

## When to Use This Pattern

Use the marketplace pattern when:
- You want to share plugins across multiple projects
- You need versioning and distribution
- You want to enable/disable plugins dynamically
- You're building a library of reusable Claude configurations

## See Also

- [Plain Example](../plain/) - Simpler direct directory management
- [Main flake.nix](../../flake.nix) - Full implementation with both patterns
