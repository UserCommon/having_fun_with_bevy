# {
#   description = "Build a cargo project";

#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

#     crane = {
#       url = "github:ipetkov/crane";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };

#     fenix = {
#       url = "github:nix-community/fenix";
#       inputs.nixpkgs.follows = "nixpkgs";
#       inputs.rust-analyzer-src.follows = "";
#     };

#     flake-utils.url = "github:numtide/flake-utils";

#     advisory-db = {
#       url = "github:rustsec/advisory-db";
#       flake = false;
#     };
#   };

#   outputs = { self, nixpkgs, crane, fenix, flake-utils, advisory-db, ... }:
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};

#         inherit (pkgs) lib;

#         craneLib = crane.mkLib pkgs;
#         src = craneLib.cleanCargoSource (craneLib.path ./.);

#         # Common arguments can be set here to avoid repeating them later
#         commonArgs = {
#           inherit src;
#           strictDeps = true;

#           buildInputs = [
#             # Add additional build inputs here
#           ] ++ lib.optionals pkgs.stdenv.isDarwin [
#             # Additional darwin specific inputs can be set here
#             pkgs.libiconv
#           ];

#           # Additional environment variables can be set directly
#           # MY_CUSTOM_VAR = "some value";
#         };

#         craneLibLLvmTools = craneLib.overrideToolchain
#           (fenix.packages.${system}.complete.withComponents [
#             "cargo"
#             "llvm-tools"
#             "rustc"
#           ]);

#         # Build *just* the cargo dependencies, so we can reuse
#         # all of that work (e.g. via cachix) when running in CI
#         cargoArtifacts = craneLib.buildDepsOnly commonArgs;

#         # Build the actual crate itself, reusing the dependency
#         # artifacts from above.
#         my-crate = craneLib.buildPackage (commonArgs // {
#           inherit cargoArtifacts;
#         });
#       in
#       {
#         checks = {
#           # Build the crate as part of `nix flake check` for convenience
#           inherit my-crate;

#           # Run clippy (and deny all warnings) on the crate source,
#           # again, reusing the dependency artifacts from above.
#           #
#           # Note that this is done as a separate derivation so that
#           # we can block the CI if there are issues here, but not
#           # prevent downstream consumers from building our crate by itself.
#           my-crate-clippy = craneLib.cargoClippy (commonArgs // {
#             inherit cargoArtifacts;
#             cargoClippyExtraArgs = "--all-targets -- --deny warnings";
#           });

#           my-crate-doc = craneLib.cargoDoc (commonArgs // {
#             inherit cargoArtifacts;
#           });

#           # Check formatting
#           my-crate-fmt = craneLib.cargoFmt {
#             inherit src;
#           };

#           # Audit dependencies
#           my-crate-audit = craneLib.cargoAudit {
#             inherit src advisory-db;
#           };

#           # Audit licenses
#           my-crate-deny = craneLib.cargoDeny {
#             inherit src;
#           };

#           # Run tests with cargo-nextest
#           # Consider setting `doCheck = false` on `my-crate` if you do not want
#           # the tests to run twice
#           my-crate-nextest = craneLib.cargoNextest (commonArgs // {
#             inherit cargoArtifacts;
#             partitions = 1;
#             partitionType = "count";
#           });
#         };

#         packages = {
#           default = my-crate;
#         } // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
#           my-crate-llvm-coverage = craneLibLLvmTools.cargoLlvmCov (commonArgs // {
#             inherit cargoArtifacts;
#           });
#         };

#         apps.default = flake-utils.lib.mkApp {
#           drv = my-crate;
#         };

#         devShells.default = import ./flake-modules/shells.nix {
#           pkgs = pkgs;
#         };
#     });
# }


{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };
        naersk' = pkgs.callPackage naersk { };
        buildInputs = with pkgs; [
          llvmPackages_latest.clang
          llvmPackages_latest.bintools
          vulkan-loader
          libxkbcommon
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          wayland
          alsa-lib
          udev
          pkg-config
        ];
        nativeBuildInputs = with pkgs; [
          (rust-bin.selectLatestNightlyWith
            (toolchain: toolchain.default.override {
              extensions = [ "rust-src" "clippy" ];
            }))
        ];
        all_deps = with pkgs; [
          cargo-flamegraph
          cargo-expand
          nixpkgs-fmt
          cmake
        ] ++ buildInputs ++ nativeBuildInputs;
      in
      rec {
        # For `nix build` & `nix run`:
        defaultPackage = packages.bevy_template;
        packages = rec {
          bevy_template = naersk'.buildPackage {
            src = ./.;
            nativeBuildInputs = nativeBuildInputs;
            buildInputs = buildInputs;
            postInstall = ''
              cp -r assets $out/bin/
            '';
            # Disables dynamic linking when building with Nix
            cargoBuildOptions = x: x ++ [ "--no-default-features" ];
          };
        };

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs = all_deps;
          shellHook = ''
            export CARGO_MANIFEST_DIR=$(pwd)
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath all_deps}"
          '';
        };
      }
    );
}


# https://blog.graysonhead.net/posts/nix-flake-rust-bevy/
# THANKS!!!
