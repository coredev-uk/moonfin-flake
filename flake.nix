{
  description = "Moonfin Flutter package flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      moonfin = pkgs.callPackage ./pkgs/moonfin.nix { };
    in
    {
      packages.${system} = {
        inherit moonfin;
        default = moonfin;
      };

      apps.${system}.default = {
        type = "app";
        program = "${moonfin}/bin/moonfin";
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
