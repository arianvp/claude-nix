{
  linkFarm,
  runCommand,
  formats,
}:
{
  name,
  description,
  mcpServers ? { },
  skills ? [ ],
}:
let
  json = formats.json { };
  # Extract skill names from skill derivations
  # The skill name is the derivation name (e.g., "pedantic-nixer")
  pluginJson = json.generate "${name}.json" {
    inherit name description mcpServers;
    skills = map (skill: "./skills/${skill.name}") skills;
  };

  # Build skills directory using linkFarm to link each skill by name
  skillsDir = linkFarm "${name}-skills" (
    map (skill: {
      name = skill.name;
      path = skill;
    }) skills
  );
in
runCommand name
  {
    passthru.meta = {
      inherit name description;
    };
  }
  ''
    mkdir -p $out/.claude-plugin
    cp ${pluginJson} $out/.claude-plugin/plugin.json
    ln -s ${skillsDir} $out/skills
  ''
