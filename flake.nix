{
  description = "nRF52840 Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      devshell,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            devshell.overlays.default
          ];
        };

        rustToolchain = pkgs.rust-bin.nightly.latest.default.override {
          targets = [ "riscv32imc-unknown-none-elf" ];
          extensions = [
            "llvm-tools"
            "rust-src"
          ];
        };
        esp-config = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
          pname = "esp-config";
          version = "0.7.0";

          src = pkgs.fetchCrate {
            inherit (finalAttrs) pname version;
            hash = "sha256-1vEdp6ln0B72xEOcd4Tci9tG3ij62IDm7Kh4HhB37Lc=";
          };

          cargoHash = "sha256-BP2AVHNkqNJ/LZtkQS4H5+x2H6YfqWu4cVMeir5Mkqs=";
          cargoDepsName = finalAttrs.pname;
        });

        device = "ESP32-C3";
      in
      {
        devShells.default = pkgs.devshell.mkShell {
          env = [
            # {
            #   name = "RUST_LOG";
            #   value = "debug";
            # }
            {
              name = "PATH";
              prefix = "$HOME/.cargo/bin/";
            }
          ];

          devshell.packages = with pkgs; [
            rustToolchain
            cargo-binutils
            esp-generate
            esp-config
            espflash # probe-rs doesn't work on the ESP32-C3 Super Mini that I have
          ];

          commands = [
            {
              category = "develop";
              name = "flash";
              command = ''
                echo "=> Flashing ${device}"
                cargo run --release
                echo "=> Finished flashing ${device}"
              '';
              help = "Flashes the ${device}";
            }
          ];
        };

      }
    );
}
