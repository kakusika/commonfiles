{
  description = "Vault with Tomet";

  nixConfig = {
    extra-substituters = [ "https://tomet.cachix.org" ];
    extra-trusted-public-keys = [ "tomet.cachix.org-1:9c/iO8Tb6YOM+3r55t12W3fOJK+66itPEaIe8Rs9MDw=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    #--- Tool ---
    sisho.url = "github:tomet-lang/sisho";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, ... }:
        let
          system = pkgs.stdenv.hostPlatform.system;
          sisho = inputs.sisho.packages.${system};
          sishoLib = inputs.sisho.legacyPackages.${system};
        in
        {
          devShells.default = pkgs.mkShell {
            # sisho, tomet, twrit, catasto and sisho-desk, with the language server.
            buildInputs = [
              (sishoLib.combine [
                sisho.toolchain
                sisho.tomet-lsp
              ])
            ];

            shellHook = ''
              echo "❄️📚️ Nix, Sisho"
            '';
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              #--- Nix ---
              nixfmt.enable = true;
              statix.enable = true;
              deadnix.enable = true;
            };

            settings = {
              global.excludes = [
                "*.lock"
              ];

              formatter.tomet = {
                command = "${sisho.tomet}/bin/tomet";
                options = [
                  "format"
                  "-i"
                ];
                includes = [ "*.tmt" ];
              };
            };
          };
        };
    };
}
