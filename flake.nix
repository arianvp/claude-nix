{
  description = "Claude Nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];
        };
        inherit (nixpkgs) lib;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        # Import library functions
        claudeLib = import ./lib { inherit pkgs; };
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        checks.formatting = treefmtEval.config.build.check self;

        packages.mcp-servers = pkgs.callPackage ./mcp-servers { };

        # Export library functions for use by other flakes
        lib = claudeLib;

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
            command = "${self.packages.${system}.mcp-servers}/node_modules/.bin/chrome-devtools-mcp";
            args = [
              "--executablePath"
              (lib.getExe pkgs.chromium)
            ];
          };
          skills = [
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
        };

        # Example marketplace using the plugins
        packages.example-marketplace = claudeLib.mkMarketplace {
          name = "mercury-marketplace";
          owner = {
            name = "Arian van Putten";
          };
          plugins = [
            self.packages.${system}.plugin-nix
            self.packages.${system}.plugin-procastinator
          ];
        };

        packages.settings = (pkgs.formats.json { }).generate "settings.json" {
          extraKnownMarketplaces = {
            mercury-marketplace = {
              source = {
                source = "directory";
                path = self.packages.${system}.example-marketplace;
              };
            };
          };
          enabledPlugins = {
            "procastinator@mercury-marketplace" = true;
            "nix@mercury-marketplace" = true;
          };
        };

        packages.claude-code = pkgs.writeShellApplication {
          name = "claude-code";
          runtimeInputs = [
            pkgs.claude-code
            # needed for claude-code's new sandbox
            pkgs.socat
            pkgs.bubblewrap
          ];
          text = ''
            # TODO: This should really be a nix store path instead of a static name
            claude plugin marketplace rm mercury-marketplace
            claude --settings ${self.packages.${system}.settings} "$@"
          '';
        };

      }

    );
}
