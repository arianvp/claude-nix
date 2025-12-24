{
  writeTextFile,
}:
{
  name,
  description,
  content,
  allowed-tools ? [ ],
}:
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
  destination = "/SKILL.md";
}
