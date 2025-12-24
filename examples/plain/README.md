# Plain Example

This example demonstrates **using `--plugin-dir`** with Nix, without marketplace abstractions.

## What is the Plain Pattern?

The plain pattern creates a wrapper script that loads plugins using `--plugin-dir`:

```bash
claude --plugin-dir /nix/store/plugin-nix-xyz \
       --plugin-dir /nix/store/plugin-foo-abc
```

Each plugin stays isolated in the Nix store, and Claude loads them directly!

## Advantages

- **Simpler**: No marketplace/plugin manager overhead
- **Direct**: Uses Claude's native `--plugin-dir` flag
- **Isolated**: Each plugin is a separate Nix derivation
- **Clean**: No merging or symlinking needed

## Usage

```bash
# Run the wrapper (builds plugins and passes them to Claude)
nix run .#claude-code

# Or use the GitHub plugin example
nix run .#claude-with-github
```

The wrapper will call `claude` with all the `--plugin-dir` flags automatically!

## When to Use This Pattern

Use the plain pattern when:
- You want a simple, project-specific Claude configuration
- You don't need to share config across projects
- You prefer direct control over the directory structure
- You're building a one-off configuration

## Structure

The `claude-code` package uses `mkClaude` to create a wrapper script:

```nix
packages.claude-code = claudeLib.mkClaude {
  plugins = [
    self.packages.${system}.plugin-nix
    # Add more plugins here
  ];
  # Optional: Add extra CLI arguments
  extraArgs = [ "--model" "opus" ];
};
```

Where plugins are built with `mkPlugin`:

```nix
packages.plugin-nix = claudeLib.mkPlugin {
  name = "nix";
  description = "Nix development tools";
  skills = [ (claudeLib.mkSkill { ... }) ];
  commands = [ (claudeLib.mkCommand { ... }) ];
  agents = [ (claudeLib.mkAgent { ... }) ];
  mcpServers = { /* MCP config goes in plugin.json */ };
};
```

This gives you:
- Type-safe configuration using Nix functions
- Reusable helper functions (`mkSkill`, `mkCommand`, `mkAgent`, `mkPlugin`)
- Proper frontmatter generation
- Embedded Nix store paths for tools
- Direct use of Claude's native `--plugin-dir` flag

## Using External Plugins from GitHub

You can also fetch plugins from external repositories using `fetchFromGitHub`:

```nix
packages.claude-with-github = let
  # Fetch the official Claude plugins repository
  claude-plugins-official = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "main";
    hash = "sha256-..."; # Get from nix build error
  };

  # Point to the specific plugin directory
  github-plugin = "${claude-plugins-official}/external_plugins/github";
in
claudeLib.mkClaude {
  plugins = [
    self.packages.${system}.plugin-nix  # Your own plugin
    github-plugin                        # External plugin
  ];
};
```

This lets you mix your own Nix-built plugins with external ones from GitHub!

## See Also

- [Marketplace Example](../marketplace/) - Full marketplace pattern with plugins
- [Main flake.nix](../../flake.nix) - Library functions and both patterns
