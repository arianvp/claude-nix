{
  description = "Example: Claude Code with direct directory management (no marketplace)";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    # Can also use: github:yourorg/claude-nix for remote
    claude-nix.url = "path:../..";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      claude-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];
        };
        inherit (nixpkgs) lib;
        claudeLib = claude-nix.lib.${system};
      in
      {
        # Define plugins using mkPlugin
        packages.plugin-nix = claudeLib.mkPlugin {
          name = "nix";
          description = "Nix development tools and helpers";
          skills = [
            (claudeLib.mkSkill {
              name = "nix-helper";
              description = "Helps with Nix development and formatting";
              allowed-tools = [
                "Bash(${pkgs.statix}/bin/statix)"
                "Bash(${pkgs.nixfmt}/bin/nixfmt)"
              ];
              content = ''
                You are a Nix expert. When working with Nix files:

                1. ALWAYS run `${pkgs.statix}/bin/statix check .` to find anti-patterns
                2. ADDRESS all issues found
                3. ALWAYS format files with `${pkgs.nixfmt}/bin/nixfmt`

                Be pedantic about best practices and code quality.
              '';
            })
          ];
          commands = [
            (claudeLib.mkCommand {
              name = "format-nix";
              description = "Format all Nix files in the project";
              allowed-tools = [
                "Bash(${pkgs.nixfmt}/bin/nixfmt)"
                "Bash(${pkgs.fd}/bin/fd)"
              ];
              argument-hint = "[directory]";
              content = ''
                Format all Nix files using nixfmt.

                If an argument is provided, format files in that directory.
                Otherwise, format all .nix files in the current directory.

                Use: ${pkgs.fd}/bin/fd -e nix -x ${pkgs.nixfmt}/bin/nixfmt
              '';
            })
          ];
          agents = [
            (claudeLib.mkAgent {
              name = "nix-analyzer";
              description = "Specialized agent for analyzing Nix code";
              tools = [
                "Read"
                "Glob"
                "Grep"
                "Bash(${pkgs.statix}/bin/statix)"
              ];
              content = ''
                You are an expert Nix code analyzer. When asked to analyze Nix code:

                1. Search for all .nix files in the project
                2. Run statix to identify anti-patterns
                3. Analyze the flake structure and dependencies
                4. Provide recommendations for improvements
                5. Explain any complex Nix patterns found

                Be thorough and educational in your analysis.
              '';
            })
          ];
        };

        # Build a .claude directory by merging plugins
        packages.claude-config = claudeLib.mkClaude {
          plugins = [
            self.packages.${system}.plugin-nix
          ];

          # Optional: Add MCP servers and settings
          mcpServers = {
            # Example MCP server configuration
            # chromium = {
            #   command = "${pkgs.chrome-devtools-mcp}/bin/chrome-devtools-mcp";
            #   args = [ "--executablePath" "${lib.getExe pkgs.chromium}" ];
            # };
          };
        };

        # Wrapper script that sets up the config and runs claude
        packages.claude-code = pkgs.writeShellApplication {
          name = "claude-code";
          runtimeInputs = [
            pkgs.claude-code
            pkgs.socat
            pkgs.bubblewrap
            pkgs.nix # Needed for nix build
          ];
          text = ''
            # Build the claude config into .claude profile
            nix build .#claude-config --profile .claude

            # Run claude with the config directory
            export CLAUDE_CONFIG_DIR="$PWD/.claude"
            claude "$@"
          '';
        };

        packages.default = self.packages.${system}.claude-code;
      }
    );
}
