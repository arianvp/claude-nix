{
  writeTextFile,
  lib,
}:
{
  name,
  description,
  content,
  tools ? [ ],
  model ? null,
}:
let
  # Build frontmatter from provided attributes
  frontmatterAttrs = lib.filterAttrs (_: v: v != null && v != [ ]) {
    inherit name description model;
    tools = if tools != [ ] then lib.concatStringsSep ", " tools else null;
  };

  # Convert attributes to YAML frontmatter
  formatValue =
    key: value:
    if builtins.isBool value then "${key}: ${lib.boolToString value}" else "${key}: ${value}";

  lines = lib.mapAttrsToList formatValue frontmatterAttrs;

  frontmatter = ''
    ---
    ${lib.concatStringsSep "\n" lines}
    ---
  '';
in
writeTextFile {
  inherit name;
  text = ''
    ${frontmatter}
    ${content}
  '';
  destination = "/${name}.md";
}
