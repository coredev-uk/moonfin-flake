{
  description = "Moonfin Flutter package flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor = system: import nixpkgs { inherit system; };
      moonfinFor = system: (pkgsFor system).callPackage ./pkgs/moonfin.nix { };

      appFor =
        system:
        let
          moonfin = moonfinFor system;
        in
        {
          type = "app";
          program = "${moonfin}/bin/moonfin";
          meta = {
            description = "Jellyfin and Emby media client";
          };
        };
    in
    {
      packages = forAllSystems (system: {
        moonfin = moonfinFor system;
        default = moonfinFor system;
      });

      apps = forAllSystems (system: {
        moonfin = appFor system;
        default = appFor system;
      });

      checks = forAllSystems (system: {
        moonfin = moonfinFor system;
        default = moonfinFor system;
      });

      overlays.default = final: prev: {
        moonfin = final.callPackage ./pkgs/moonfin.nix { };
      };

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
