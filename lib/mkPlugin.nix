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
  commands ? [ ],
  agents ? [ ],
}:
let
  json = formats.json { };

  # Normalize skills to handle both plain paths and derivations
  normalizeSkill =
    skill:
    if builtins.isPath skill then
      # For plain paths, extract the basename as the name
      let
        skillName = baseNameOf skill;
      in
      {
        name = skillName;
        path = skill;
      }
    else
      # For derivations, use the .name attribute
      {
        inherit (skill) name;
        path = skill;
      };

  normalizedSkills = map normalizeSkill skills;

  # Extract skill names from skill derivations
  # The skill name is the derivation name (e.g., "pedantic-nixer")
  pluginJson = json.generate "${name}.json" {
    inherit name description mcpServers;
    skills = map (skill: "./skills/${skill.name}") normalizedSkills;
    commands = map (command: "./commands/${command.name}.md") commands;
    agents = map (agent: "./agents/${agent.name}.md") agents;
  };

  # Build skills directory using linkFarm to link each skill by name
  skillsDir = linkFarm "${name}-skills" normalizedSkills;

  # Build commands directory using linkFarm to link to the .md files directly
  commandsDir = linkFarm "${name}-commands" (
    map (command: {
      name = "${command.name}.md";
      path = "${command}/${command.name}.md";
    }) commands
  );

  # Build agents directory using linkFarm to link to the .md files directly
  agentsDir = linkFarm "${name}-agents" (
    map (agent: {
      name = "${agent.name}.md";
      path = "${agent}/${agent.name}.md";
    }) agents
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
    ${if skills != [ ] then "ln -s ${skillsDir} $out/skills" else ""}
    ${if commands != [ ] then "ln -s ${commandsDir} $out/commands" else ""}
    ${if agents != [ ] then "ln -s ${agentsDir} $out/agents" else ""}
  ''
