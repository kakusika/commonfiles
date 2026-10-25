{
  pkgs,
  tomet,
  ...
}:
{
  projectRootFile = "flake.nix";
  programs = {
    #= Nix
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;

    #= Shell
    shfmt.enable = true;
    shellcheck.enable = true;

    #= Main
    rustfmt.enable = true;
    taplo.enable = true;
    ktlint.enable = true;
  };

  settings = {
    global.excludes = [
      "*.lock"
      "patches/**"
    ];

    formatter = {
      tomet = {
        command = "${tomet}/bin/tomet";
        options = [
          "fmt"
          "--file"
        ];
        includes = [ "*.tmt" ];
      };

      slint = {
        command = "${pkgs.slint-lsp}/bin/slint-lsp";
        options = [
          "format"
          "-i"
        ];
        includes = [ "*.slint" ];
      };
    };
  };
}
