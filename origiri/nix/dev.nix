{
  lib,
  pkgs,
  mkShell,
  fenix,
  tools,
  ...
}:
let
  rustToolchain = fenix.combine [
    (fenix.stable.withComponents [
      "cargo"
      "clippy"
      "rustc"
      "rust-src"
      "rustfmt"
      "rust-analyzer"
    ])
  ];
in
mkShell rec {
  hardeningDisable = [ "fortify" ];

  buildInputs = with pkgs; [
    #= Develop
    tools
    just
    #== Slint
    slint-lsp
    slint-viewer
    slint-tr-extractor
    #== Build
    pkg-config
    cmake
    ninja
    llvmPackages.libclang
    python3
    uv
    #== Rust
    rustToolchain
    cargo-edit
    cargo-outdated
    cargo-nextest
    wasm-bindgen-cli
    mold
    stdenv.cc.cc.lib # Skia's prebuilt binary links against libstdc++

    #= Runtime
    #== Wayland & Desktop
    wayland
    libxkbcommon
    libinput
    pipewire
    alsa-lib
    openssl
    glib
    fontconfig
    freetype
    fcitx5

    #== Graphics
    libGL
    mesa
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];

  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS =
    "-isystem ${pkgs.stdenv.cc.cc}/include/c++/${pkgs.stdenv.cc.cc.version} "
    + "-isystem ${pkgs.stdenv.cc.cc}/include/c++/${pkgs.stdenv.cc.cc.version}/${pkgs.stdenv.hostPlatform.config} "
    + "-isystem ${pkgs.stdenv.cc.libc.dev}/include";

  PKG_CONFIG_PATH = lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
    pkgs.openssl
    pkgs.fontconfig
    pkgs.freetype
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.alsa-lib
    pkgs.fcitx5
  ];

  LD_LIBRARY_PATH =
    lib.makeLibraryPath [
      pkgs.openssl
      pkgs.wayland
      pkgs.libxkbcommon
      pkgs.pipewire
      pkgs.alsa-lib
      pkgs.fontconfig
      pkgs.freetype
      pkgs.mesa
      pkgs.libGL
      pkgs.vulkan-loader
      pkgs.fcitx5
      pkgs.stdenv.cc.cc.lib
    ]
    + ":/run/opengl-driver/lib";

  VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";

  shellHook = ''
    echo "🍙 Origiri dev shell (Rust + Slint + Tomet)"
  '';
}
