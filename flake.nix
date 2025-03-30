{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, fenix, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
#        libunwind = pkgs.libunwind.overrideAttrs(old: {
#          src = pkgs.fetchFromGitHub {
#            owner = "libunwind";
#            repo = "libunwind";
#            rev = "b31806304b66a5e50ac738ac8c719db0ebc0fdf6";
#            hash = "sha256-BkfBQ7dXOF0VyJH72IMDnDrMOkImkk9GAOyBlZAKIcM=";
#          };
#        });
#        libunwind-x86 = libunwind.overrideAttrs(old: {
#          configureFlags = old.configureFlags ++ [
#            "--target=x86-linux"
#            "--enable-coredump=false"
#          ];
#        });
#        perf-llvm = pkgs.linuxPackages_5_15.perf.overrideAttrs (base: {
#          dontStrip = true;
#          env = (base.env or {}) // { NIX_CFLAGS_COMPILE = toString (base.env.NIX_CFLAGS_COMPILE or "") + " -ggdb"; };
#          buildInputs = base.buildInputs ++ [pkgs.llvmPackages.libllvm libunwind libunwind-x86];
#          nativeBuildInputs = base.nativeBuildInputs ++ [libunwind.dev libunwind-x86.dev];
#          hardeningDisable = ["all"];
#        });
#        perf_data_converter = pkgs.perf_data_converter.overrideAttrs (old: {
#          version = "git";
#          src = pkgs.fetchFromGitHub {
#            owner = "mloc";
#            repo = "perf_data_converter";
#            rev = "dwarf";
#            hash = "sha256-T5SrwT/a5TMLxqNoNulzkxFYtjqXLm1tl7lBXTLyz34=";
#          };
#          deps = old.deps.overrideAttrs (oldDeps: {
#            outputHash = "sha256-TYeS1bax7sA0hJLXqtE8Q5FLnIylcWPZynVE2LhvZKc=";
#            src = pkgs.fetchFromGitHub {
#              owner = "mloc";
#              repo = "perf_data_converter";
#              rev = "dwarf";
#              hash = "sha256-T5SrwT/a5TMLxqNoNulzkxFYtjqXLm1tl7lBXTLyz34=";
#            };
#          });
#        });
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.pkgsi686Linux.mimalloc
            pkgs.pkgsi686Linux.gperftools
            pkgs.pkgsi686Linux.jemalloc
            #perf-llvm
            #perf_data_converter
          ];
          buildInputs = [
          ];
          MIMALLOC_LIB="${pkgs.pkgsi686Linux.mimalloc}/lib/libmimalloc.so";
          TCMALLOC_LIB="${pkgs.pkgsi686Linux.gperftools}/lib/libtcmalloc.so";
          JEMALLOC_LIB="${pkgs.pkgsi686Linux.jemalloc}/lib/libjemalloc.so";
        };
      });
}