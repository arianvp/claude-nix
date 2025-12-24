{
  pkgs,
  lib,
  writeShellApplication,
}:
{
  plugins ? [ ],
  extraArgs ? [ ],
}:
let
  # Generate --plugin-dir flags for each plugin
  pluginDirFlags = lib.concatMapStringsSep " " (plugin: "--plugin-dir ${plugin}") plugins;

  # Combine all extra args
  allExtraArgs = lib.concatStringsSep " " extraArgs;
in
writeShellApplication {
  name = "claude";
  runtimeInputs = [ pkgs.claude-code ];
  text = ''
    exec claude ${pluginDirFlags} ${allExtraArgs} "$@"
  '';
}
