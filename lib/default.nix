{ pkgs }:
{
  mkSkill = pkgs.callPackage ./mkSkill.nix { };

  mkCommand = pkgs.callPackage ./mkCommand.nix { };

  mkAgent = pkgs.callPackage ./mkAgent.nix { };

  mkPlugin = pkgs.callPackage ./mkPlugin.nix { };

  mkMarketplace = pkgs.callPackage ./mkMarketplace.nix { };

  mkClaudeCode = pkgs.callPackage ./mkClaudeCode.nix { };
}
