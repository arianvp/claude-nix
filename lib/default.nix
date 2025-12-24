{ pkgs }:
{
  mkSkill = pkgs.callPackage ./mkSkill.nix { };

  mkCommand = pkgs.callPackage ./mkCommand.nix { };

  mkAgent = pkgs.callPackage ./mkAgent.nix { };

  mkPlugin = pkgs.callPackage ./mkPlugin.nix { };

  mkClaudeCode = pkgs.callPackage ./mkClaudeCode.nix { };

  # Direct .claude directory builder (no marketplace abstraction)
  mkClaude = pkgs.callPackage ./mkClaude.nix { };
}
