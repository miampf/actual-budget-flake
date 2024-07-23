{
  description = "A flake for actual-server.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {inherit system;};
      in
      {
        packages = {
          default = self.packages.${system}.actualBudgetDesktop;
          actualBudgetDesktop = pkgs.callPackage ./actual-desktop.nix {};
        };
      }
    ) // {
      nixosModules.actual-server = ./module.nix;
      overlays.default = final: prev: {inherit (self.packages.${prev.system}) actualBudgetDesktop;};
    };
}
