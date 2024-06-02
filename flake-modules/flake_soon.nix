{
    description = "Bevy project";

    inputs = {
        nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

        flake-parts.url = "github:hercules-ci/flake-parts";

        crane = {
            url = "github:ipetkov/crane";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        fenix = {
            url = "github:nix-community/fenix";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.rust-analyzer-srs.follows = "";
        };

    };

    outputs = inputs:
        inputs.flake-parts.lib.mkFlake {inherit inputs;} {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            imports = [
                ./flake-modules/rust-toolchain.nix
                ./flake-modules/shells.nix
                ./flake-modules/cargo.nix
            ];
        };
        # flake-utils.lib.eachDefaultSystem
        # (system:
        #     let
        #         pkgs = nixpkgs.legacyPackages.${system};

        #         inherit (pkgs) lib;

        #         craneLib = crane.mkLib pkgs;
        #         src = craneLib.cleanCargoSource (craneLib.path ./.);

        #         craneLibLLvmTools = craneLib.overrideToolchain
        #             (feinx.packages.${system}.complete.withComponents [
        #                 "cargo"
        #                 "llvm-tools"
        #                 "rustc"
        #             ]);

        #         cargoArtifacts = craneLib.buildDepsOnly buildInputs
        #     in
        #     {
        #         devShells.default = import ./shell.nix {
        #              pkgs = pkgs;
        #         };
        #     }
        # );
}
