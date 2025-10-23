{ writeTextDir, lib }:

path: frontmatter: content:

let
  # Filter out null values and empty lists
  cleanedAttrs = lib.filterAttrs (_: v: v != null && v != [ ]) frontmatter;

  frontmatterText =
    if cleanedAttrs == { } then
      ""
    else
      ''
        ---
        ${builtins.toJSON cleanedAttrs}
        ---
      '';
in
writeTextDir path ''
  ${frontmatterText}${content}
''
