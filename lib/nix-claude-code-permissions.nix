{ stdenvNoCC, jq }:
{ rootPaths }:

stdenvNoCC.mkDerivation {
  name = "closure-info";

  __structuredAttrs = true;

  exportReferencesGraph.closure = rootPaths;

  preferLocalBuild = true;

  nativeBuildInputs = [
    jq
  ];

  buildCommand = ''
    out=''${outputs[out]}
    mkdir $out

    jq '
      {
        "permissions": {
          "allow": (
            [.closure[] | .path] |
            map("Read(/\(.)/)")
          )
        }
      }
    ' "$NIX_ATTRS_JSON_FILE" > $out/claude-permissions.json
  '';
}
