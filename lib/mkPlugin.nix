{
  buildEnv,
  runCommand,
  formats,
}:
{
  name,
  description,
  mcpServers ? { },
  lspServers ? { },
  skills ? [ ],
  commands ? [ ],
  agents ? [ ],
}:
let
  json = formats.json { };

  pluginJsonDrv = runCommand "${name}-plugin-json" { } ''
    mkdir -p $out/.claude-plugin
    cp ${json.generate "plugin.json" {
      inherit
        name
        description
        mcpServers
        lspServers
        ;
    }} $out/.claude-plugin/plugin.json
  '';
in
buildEnv {
  inherit name;
  paths = [ pluginJsonDrv ] ++ skills ++ commands ++ agents;
  pathsToLink = [
    "/.claude-plugin"
    "/skills"
    "/commands"
    "/agents"
  ];
  passthru.meta = {
    inherit name description;
  };
}
