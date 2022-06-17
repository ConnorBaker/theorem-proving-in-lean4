{
  description = "Lean documentation";

  nixConfig = {
    extra-substituters = [
      # Lean 4 cache
      "https://lean4.cachix.org"

      # Cache I set up
      "https://cantcache.me"
    ];
    extra-trusted-public-keys = [
      # Public key for Lean 4
      "lean4.cachix.org-1:mawtxSxcaiWE24xCXXgh3qnvlTkyU7evRRnGeAhD4Wk="

      # Public key for cantcache.me
      "cantcache.me:Y+FHAKfx7S0pBkBMKpNMQtGKpILAfhmqUSnr5oNwNMs="
    ];
  };

  inputs.lean.url = github:leanprover/lean4;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.mdBook = {
    url = github:leanprover/mdBook;
    flake = false;
  };
  inputs.alectryon-src = {
    # Upstream fork does not support lean4+markup yet, use Sebastien's fork
    url = github:Kha/alectryon/typeid;
    flake = false;
  };
  inputs.leanInk-src = {
    # Broken from this commit onwards:
    url = github:leanprover/LeanInk/ad9f1b2d518852cd25063d590a7fbea98e047471;
    flake = false;
  };

  outputs = {
    self,
    lean,
    flake-utils,
    mdBook,
    alectryon-src,
    leanInk-src,
  }:
    flake-utils.lib.eachDefaultSystem (system:
      with lean.packages.${system}; with nixpkgs; let
        doc-src = ./doc-src;

        # Define some packages we use to build docs
        leanInk =
          (buildLeanPackage {
            name = "LeanInk";
            src = leanInk-src;
            executableName = "leanInk";
            linkFlags = ["-rdynamic"];
          })
          .executable;
        alectryon = python310Packages.buildPythonApplication {
          name = "alectryon";
          src = alectryon-src;
          propagatedBuildInputs =
            [leanInk lean-all]
            ++
            # https://github.com/cpitclaudel/alectryon/blob/master/setup.cfg
            (with python310Packages; [pygments dominate beautifulsoup4 docutils]);
          doCheck = false;
        };
        lean-mdbook = mdbook.overrideAttrs (drv: rec {
          name = "lean-${mdbook.name}";
          src = mdBook;
          cargoDeps = drv.cargoDeps.overrideAttrs (_: {
            inherit src;
            outputHash = "sha256-5cAV8tOU3R1cPubseetURDQOzKyoo4485wD5IgeJUhQ=";
          });
          doCheck = false;
        });

        # Generate the lean markdown using alectryon
        generated-lean-markdown = let
          inputs = lib.sources.sourceFilesBySuffices doc-src [".lean"];
          outputs = runCommand "generated-lean-markdown" {buildInputs = [alectryon];} ''
              for file in $(find ${inputs} -type f -printf "%P "); do
                mkdir -p $out/$(dirname $file)
                alectryon --frontend lean4+markup ${inputs}/$file --backend webpage -o $out/$file.md
              done
            '';
        in
          symlinkJoin {
            name = "doc";
            paths = outputs;
          };

        doc = stdenv.mkDerivation {
            name = "lean-doc";
            src = doc-src;
            buildInputs = [lean-mdbook];
            buildCommand = ''
              mkdir $out
              # necessary for `additional-css`...?
              cp -r --no-preserve=mode $src/* .
              # overwrite stub .lean.md files
              cp -r ${generated-lean-markdown}/* .
              # test the fragments
              mdbook test
              # build the book
              mdbook build -d $out
            '';
          };

      in {
        packages = {
          inherit leanInk alectryon lean-mdbook generated-lean-markdown doc;
          default = doc;
        };

        devShells.default = mkShell {
          packages = [(builtins.attrValues self.packages.${system}) lean-all];
        };
      });
}
