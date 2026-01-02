{
  pkgs,
  lib,
  writeShellApplication,
}:
{
  plugins ? [ ],
}:
let
  pluginDirFlags = lib.cli.toCommandLineShellGNU {} { plugin-dir = plugins; };
in
writeShellApplication {
  name = "claude";
  runtimeInputs = [ pkgs.claude-code ];
  text = ''
    exec claude ${pluginDirFlags} "$@"
  '';
}
