{
  description = "Claude Nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable-small";
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
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];
        };
        inherit (nixpkgs) lib;

        # Import library functions
        claudeLib = import ./lib { inherit pkgs; };
      in
      {
        # Export library functions for use by other flakes
        lib = claudeLib;
      }
    );
}
