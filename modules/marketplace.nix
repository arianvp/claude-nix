{ lib, ... }:

let
  plugin = {
    options = {
      mcpServers = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              command = lib.mkOption {
                type = lib.types.path;
              };
              args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        );
      };
    };
  };
in
{
  options.plugins = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule plugin);
  };

}
