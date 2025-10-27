{
  linkFarm,
  runCommand,
  formats,
}:
{
  name,
  owner,
  plugins ? [ ],
}:
let
  json = formats.json { };
  # Extract plugin metadata from derivations
  # Plugin name comes from derivation name, description from passthru.meta
  marketplaceJson = json.generate "marketplace.json" {
    inherit name owner;
    plugins = map (plugin: {
      inherit (plugin) name;
      inherit (plugin.meta) description;
      source = "./plugins/${plugin.name}";
    }) plugins;
  };

  # Build plugins directory by linking each plugin to its name
  pluginsDir = linkFarm "${name}-plugins" (
    map (plugin: {
      inherit (plugin) name;
      path = plugin;
    }) plugins
  );
in
runCommand "claude-marketplace-${name}" { } ''
  mkdir -p $out/.claude-plugin
  cp ${marketplaceJson} $out/.claude-plugin/marketplace.json
  ln -s ${pluginsDir} $out/plugins
''
