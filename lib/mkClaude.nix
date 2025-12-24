{
  pkgs,
  lib,
  symlinkJoin,
}:
{
  plugins ? [ ],
  mcpServers ? { },
  settings ? { },
}:
let
  json = pkgs.formats.json { };

  # Merge all plugin directories together
  # This symlinks all skills/, commands/, agents/ dirs into one
  mergedPlugins =
    if plugins == [ ] then
      pkgs.runCommand "empty-claude-config" { } ''
        mkdir -p $out/skills $out/commands $out/agents
      ''
    else
      symlinkJoin {
        name = "claude-config";
        paths = plugins;
      };

  # Generate settings.json if mcpServers or settings are provided
  settingsConfig = {
    inherit mcpServers;
  }
  // settings;
  hasSettings = mcpServers != { } || settings != { };

  # If we have settings, we need to add them to the merged plugins
  finalConfig =
    if hasSettings then
      pkgs.runCommand "claude-config-with-settings" { } ''
        mkdir -p $out
        # Copy all plugin contents
        ${lib.optionalString (plugins != [ ]) ''
          cp -rL ${mergedPlugins}/* $out/
        ''}
        # Ensure directories exist even if no plugins
        mkdir -p $out/skills $out/commands $out/agents
        # Add settings.json
        cp ${json.generate "settings.json" settingsConfig} $out/settings.json
      ''
    else
      mergedPlugins;
in
finalConfig
