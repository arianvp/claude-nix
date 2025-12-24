{
  description = "Example: Claude Code with direct directory management (no marketplace)";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    # Can also use: github:yourorg/claude-nix for remote
    claude-nix = {
      url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

        # Build a claude wrapper that loads plugins via --plugin-dir
        packages.claude-code = claudeLib.mkClaude {
          plugins = [
            self.packages.${system}.plugin-nix
          ];
          # Optional: Add extra CLI arguments
          # extraArgs = [ "--model" "opus" ];
        };

        # Example: Using external plugins from GitHub
        # Fetch and use plugins directly from the official Claude plugins repository
        packages.claude-with-github =
          let
            # Fetch the official Claude plugins repository
            claude-plugins-official = pkgs.fetchFromGitHub {
              owner = "anthropics";
              repo = "claude-plugins-official";
              rev = "main"; 
              hash = "sha256-JZNy8pFiYe2+vGkXO3jlBz0GGB1m95AWScNcHAL8kxM=";
            };
            github-plugin = "${claude-plugins-official}/external_plugins/github";
          in
          claudeLib.mkClaude {
            plugins = [
              # Mix your own plugins with external ones from GitHub
              self.packages.${system}.plugin-nix
              github-plugin
            ];
          };

        packages.default = self.packages.${system}.claude-code;
      }
    );
}
