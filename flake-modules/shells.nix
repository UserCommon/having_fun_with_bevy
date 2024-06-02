{pkgs}:
let
    llvm = pkgs.llvmPackages;

    bevyInputs = with pkgs; [
        udev alsa-lib vulkan-loader
        xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr # To use the x11 feature
        libxkbcommon wayland # To use the wayland feature

        libGL
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
                     ++ bevyInputs
                     ++ otherInputs;


    # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

    shellHook = ''
        alias run="cargo run --features bevy/dynamic_linking"
    '';

    RUST_BACKTRACE = "full";
}
