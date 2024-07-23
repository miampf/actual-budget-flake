{
  description = "A flake for actual-server.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      {
      }
    ) // {
      nixosModules.actual-server = ./module.nix;
    };
}
