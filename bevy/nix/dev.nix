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
  buildInputs = with pkgs; [
    #= Develop & Orchestration
    tools
    just

    #= Build Tools
    pkg-config
    clang
    lld

    #= Rust Toolchain & Utilities
    rustToolchain
    cargo-edit
    cargo-outdated
    cargo-nextest

    #= Bevy Runtime & Graphics
    # System
    udev
    alsa-lib

    # Wayland
    wayland
    wayland-protocols
    libxkbcommon

    # X11 fallback
    libx11
    libxcursor
    libxi
    libxrandr
    libxinerama

    # Vulkan & OpenGL
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
    libGL
    mesa
  ];

  PKG_CONFIG_PATH = lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
    pkgs.udev
    pkgs.alsa-lib
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.vulkan-loader
    pkgs.libx11
    pkgs.libxcursor
    pkgs.libxi
    pkgs.libxrandr
  ];

  LD_LIBRARY_PATH =
    lib.makeLibraryPath [
      pkgs.vulkan-loader
      pkgs.alsa-lib
      pkgs.udev
      pkgs.wayland
      pkgs.libxkbcommon
      pkgs.libx11
      pkgs.libxcursor
      pkgs.libxi
      pkgs.libxrandr
      pkgs.libGL
      pkgs.mesa
    ]
    + ":/run/opengl-driver/lib";

  WINIT_UNIX_BACKEND = "wayland";

  shellHook = ''
    echo "🦀🎮 Rust Bevy + Tomet"
  '';
}
