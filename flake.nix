{
  description = "Using Claude Code with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        json = pkgs.formats.json { };
      in
      {
        packages.nix-claude-code-permissions = pkgs.callPackage ./nix-claude-code-permissions.nix { } {
          rootPaths = [ pkgs.nginx ];
        };

        packages.mcp-servers = pkgs.callPackage ./mcp-servers.nix { };

        /*
          claudePlugins.default = json.generate "plugin.json" {
          	  mcpServers = {
          	    "chromium" = {
          	    };
          	  };
          	  hooks.PostToolUse = [
          	    matcher = "Write|Edit";
                      hooks = [  { type = "command"; command = pkgs.nixfmt; } ];
          	  ];
          	};
        */

        /*
          claudePlugins.example =
              let
                lib = nixpkgs.lib;
                nixos-option = lib.getExe pkgs.nixos-option;
                nixfmt = lib.getExe pkgs.nixfmt;
              in
              pkgs.writers.writeJSON "plugin.json" {
                name = "nix";
                commands = [
                  (pkgs.writeText "nixos-options.md" ''
                    ---
                    allowed-tools: Bash(${nixos-option}:*)
                    ---
                    Use `${nixos-option} --flake .` to lazily browse options.
                    Use `${nixos-option} --flake . <option>` will give you details about the option or sub-options.
                    Responds with an example on how to use the option and the docs.
                  '')
                ];
                hooks.PostToolUse = [
                  {
                    matcher = "Write|Edit";
                    hooks = [
                      {
                        type = "command";
                        command = nixfmt;
                      }
                    ];
                  }
                ];
                mcpServers = {
                };
              };
        */
      }
    );
}
