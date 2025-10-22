{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    statix.enable = true;
    nixf-diagnose.enable = true;
    yamlfmt.enable = true;
  };
}
