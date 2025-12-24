{
  pkgs,
  lib,
  writeShellApplication,
  formats,
}:
{
  marketplaces ? { },
  enabledPlugins ? { },
  extraSettings ? { },
  extraRuntimeInputs ? [ ],
}:
let
  json = formats.json { };

  # Build the marketplaces configuration for settings
  # Maps marketplace name -> Claude's expected format with source type and path
  extraKnownMarketplaces = builtins.mapAttrs (name: _marketplace: {
    source = {
      source = "directory";
      path = "./.claude-nix/marketplaces/${name}";
    };
  }) marketplaces;

  # Generate settings JSON file
  settingsConfig = {
    inherit extraKnownMarketplaces;
    inherit enabledPlugins;
  }
  // extraSettings;

  settingsFile = json.generate "settings.json" settingsConfig;

  # Extract marketplace package names and build commands
  # Each marketplace derivation gets built and linked
  marketplaceBuilds = lib.mapAttrsToList (name: marketplace: ''
    mkdir -p .claude-nix/marketplaces
    nix build .#${name} --profile .claude-nix/marketplaces/${name}
  '') marketplaces;
in
writeShellApplication {
  name = "claude-code";
  runtimeInputs = [
    pkgs.claude-code
    # needed for claude-code's new sandbox
    pkgs.socat
    pkgs.bubblewrap
  ]
  ++ extraRuntimeInputs;
  text = ''
    # Build and link marketplaces
    ${lib.concatStringsSep "\n" marketplaceBuilds}

    # Run claude with settings
    claude --settings ${settingsFile} "$@"
  '';
}
