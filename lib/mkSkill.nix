{
  writeTextFile,
}:
{
  name,
  description,
  allowed-tools ? [ ],
}:
content:
writeTextFile {
  inherit name;
  text = ''
    ---
    name: ${name}
    description: ${description}
    allowed-tools: ${toString allowed-tools}
    ---
    ${content}
  '';
  destination = "/skills/${name}/SKILL.md";
}
