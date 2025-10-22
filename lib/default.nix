{ pkgs }:
{
  mkSkill = pkgs.callPackage ./mkSkill.nix { };

  mkPlugin = pkgs.callPackage ./mkPlugin.nix { };

  mkMarketplace = pkgs.callPackage ./mkMarketplace.nix { };
}
