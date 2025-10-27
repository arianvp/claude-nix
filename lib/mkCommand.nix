{
  writeTextFile,
  lib,
}:
{
  name,
  description ? null,
  content,
  allowed-tools ? [ ],
  argument-hint ? null,
  model ? null,
  disable-model-invocation ? false,
}:
let
  # Build frontmatter from provided attributes
  frontmatterAttrs = lib.filterAttrs (_: v: v != null && v != [ ]) {
    inherit description model;
    allowed-tools = if allowed-tools != [ ] then allowed-tools else null;
    inherit argument-hint;
    disable-model-invocation = if disable-model-invocation then true else null;
  };

  # Convert attributes to YAML frontmatter
  frontmatter =
    if frontmatterAttrs != { } then
      let
        formatValue =
          key: value:
          if builtins.isBool value then
            "${key}: ${lib.boolToString value}"
          else if builtins.isList value then
            "${key}: ${toString value}"
          else
            "${key}: ${value}";
        lines = lib.mapAttrsToList formatValue frontmatterAttrs;
      in
      ''
        ---
        ${lib.concatStringsSep "\n" lines}
        ---
      ''
    else
      "";
in
writeTextFile {
  inherit name;
  text = ''
    ${frontmatter}${content}
  '';
  destination = "/${name}.md";
}
