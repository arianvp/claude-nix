{ importNpmLock, nodejs }:
importNpmLock.buildNodeModules {
  npmRoot = ./.;
  inherit nodejs;
}
