{
    description = "Bevy project";

    inputs = {
        flake-utils.url = "github:numtide/flake-utils";
        nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
        rust-overlay.url = "github:oxalica/rust-overlay";
    };

    outputs = {
        self,
        nixpkgs,
        flake-utils,
        rust-overlay,
        ...
    }:
        flake-utils.lib.eachDefaultSystem
        (system:
            let
                overlays = [ (import rust-overlay) ];

                pkgs = import nixpkgs {
                    inherit system overlays;
                };
            in
            {
                devShells.default = import ./shell.nix {
                     pkgs = pkgs;
                };
            }
        );
}
