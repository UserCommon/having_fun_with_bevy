{pkgs}:
let
    llvm = pkgs.llvmPackages_latest;

    bevyInputs = with pkgs; [
        udev alsa-lib vulkan-loader
        xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr # To use the x11 feature
        libxkbcommon wayland # To use the wayland feature

        libGL
    ];

    rustInputs = with pkgs; [
        (rust-bin.stable.latest.default.override {
            targets = ["x86_64-unknown-linux-gnu"];
            extensions = [ "rust-src" "rust-analyzer" "clippy" ];
        })
    ];

    clangInputs = with llvm; [
        clang
        # llvm
        bintools
    ];

    otherInputs = with pkgs; [
        mold
        eza
    ];

in
pkgs.mkShell rec {
    nativeBuildInputs = with pkgs; [
        pkg-config
    ];

    buildInputs = [] ++ clangInputs
                     ++ rustInputs
                     ++ bevyInputs
                     ++ otherInputs;


    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
    RUST_BACKTRACE = "full";
}
