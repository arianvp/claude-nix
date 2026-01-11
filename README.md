# claude-nix

Manage Claude Skills, Commands, MCPs and LSPs using nix!

Use nix to give Skills and Commands access to thousands of packages in [nixpkgs],
and to make sure that all your colleagues are running the same MCP and LSP versions.


## Example

```

lib.mkSkill {
  name = "pandoc";
  description = "Use this skill to convert between document types";
  allowed-tools = "Bash(${pkgs.pandoc}/bin/pandoc:*)";
  skill = ''
  * Use the `pandoc` command to convert from one document type to another.
  * Use `pandoc --help` to see all the different source and targets
  '';
}

```


## Why?

Claude-code is amazing, but they somehow invented the worst package manager on earth,
stealing the crown from  [Github Actions].

The "Claude Marketplace" has no pinning, no dependency resolution, and worst of all,
most plugins in turn just call out to `npx` or `uvx` to install unpinned versions of
nodejs and python packages.  In the light of the series of Shai Hulud worms pwning
several major companies, running agents with unpinned dependencies from the web
is not only annoying for reproducibility, it *will* get you hacked.

Claude-nix shows how you can manage your `.claude` folder with Nix! The cool
thing about nix is that we we can easily make our Claude Skills 

