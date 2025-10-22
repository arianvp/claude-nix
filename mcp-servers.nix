{ mkYarnModules, }:
mkYarnModules  {  pname = "mcp-servers"; version = "0.0"; yarnLock = ./. +  "/yarn.lock"; packageJSON =  ./. + "/package.json"; }
