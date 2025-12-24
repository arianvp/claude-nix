{
  description = "Example: Claude Code with marketplace pattern";
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
        # Example plugins
        packages.plugin-nix = claudeLib.mkPlugin {
          name = "nix";
          description = "Configures Claude Code to be a Nix monster";
          mcpServers = { };
          skills = [
            (claudeLib.mkSkill {
              name = "pedantic-nixer";
              description = "Makes sure your configs are anti-pattern free and without errors";
              allowed-tools = [
                "Bash(${pkgs.statix}/bin/statix)"
                "Bash(${pkgs.nixfmt}/bin/nixfmt)"
              ];
              content = ''
                ALWAYS run `${pkgs.statix}/bin/statix` on files you edit to find anti-patterns
                ADDRESS all issues for you

                Also ALWAYS format files with ${pkgs.nixfmt}/bin/nixfmt
              '';
            })
          ];
        };

        packages.plugin-procastinator = claudeLib.mkPlugin {
          name = "procastinator";
          description = "Browses hacker news using Chromium's built-in MCP";
          mcpServers.chromium = {
            command = "${claude-nix.packages.${system}.mcp-servers}/node_modules/.bin/chrome-devtools-mcp";
            args = [
              "--executablePath"
              (lib.getExe pkgs.chromium)
            ];
          };
          skills = [
            (claudeLib.mkSkill {
              name = "joke-teller";
              description = "Tells a funny joke";
              allowed-tools = [ ];
              content = ''
                Tell the user a programming joke.
              '';
            })
            (claudeLib.mkSkill {
              name = "procastinator";
              description = "Procastinate by browsing to xkcd";
              allowed-tools = [ "chromium__navigate_page" ];
              content = ''
                ## How to procastinate
                * MUST Open https://xkcd.com
                * Tell me what is the joke
              '';
            })
          ];
          commands = [
            (claudeLib.mkCommand {
              name = "browse-xkcd";
              description = "Browse to xkcd and explain the current comic";
              allowed-tools = [ "chromium__navigate_page" ];
              argument-hint = "[comic number]";
              content = ''
                Browse to https://xkcd.com (or https://xkcd.com/$1 if a comic number is provided).
                Explain the joke in the comic to the user.
              '';
            })
          ];
          agents = [
            (claudeLib.mkAgent {
              name = "xkcd-explainer";
              description = "Specialized agent for explaining xkcd comics";
              tools = [
                "chromium__navigate_page"
                "chromium__take_snapshot"
              ];
              content = ''
                You are an expert at explaining xkcd comics. When given an xkcd URL or comic number:
                1. Navigate to the comic
                2. Take a snapshot to see it
                3. Provide a detailed explanation of the joke, including any relevant context
                4. Explain technical references if applicable
              '';
            })
          ];
        };

        # Example marketplace using the plugins
        packages.mercury-marketplace = claudeLib.mkMarketplace {
          name = "mercury-marketplace";
          owner = {
            name = "Arian van Putten";
          };
          plugins = [
            self.packages.${system}.plugin-nix
            self.packages.${system}.plugin-procastinator
          ];
        };

        packages.claude-code = claudeLib.mkClaudeCode {
          marketplaces = {
            inherit (self.packages.${system}) mercury-marketplace;
          };
          enabledPlugins = {
            "procastinator@mercury-marketplace" = true;
            "nix@mercury-marketplace" = true;
          };
        };

        packages.default = self.packages.${system}.claude-code;
      }
    );
}
