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
    url = github:leanprover/LeanInk;
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
      with lean.packages.${system};
      with nixpkgs; let
        python = python310;
        doc-src = ./doc-src;

        # Define some packages we use to build docs
        leanInk =
          (buildLeanPackage {
            name = "Main";
            src = leanInk-src;
            deps = [
              (buildLeanPackage {
                name = "LeanInk";
                src = leanInk-src;
              })
            ];
            executableName = "leanInk";
            linkFlags = ["-rdynamic"];
          })
          .executable;
        alectryon = python.pkgs.buildPythonApplication {
          name = "alectryon";
          src = alectryon-src;
          buildInputs = with python.pkgs; [beautifulsoup4];
          propagatedBuildInputs =
            [leanInk lean-all]
            ++
            # https://github.com/cpitclaudel/alectryon/blob/master/setup.cfg
            (with python.pkgs; [pygments dominate]);
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
              # Typecheck the lean file.
              # Lean exits with status code 1 if the code does not typecheck.
              echo "Typechecking $file..."
              errors=$(lean ${inputs}/$file | grep "error: " || echo "")
              if [[ ! -z "$errors" ]]; then
                echo "Failed to typecheck $file!"
                echo "$errors"
                exit 1
              fi
              echo "Successfully typechecked $file"
              # Don't use --html-minification or --html-dialect html5 because
              # they insert quoted character literals after `#check`
              # statements for some reason.
              alectryon --frontend lean4+markup --backend webpage \
                ${inputs}/$file --output $out/$file.md
            done
          '';
        in
          symlinkJoin {
            name = "doc";
            paths = outputs;
          };

        docs = stdenv.mkDerivation {
          name = "lean-doc";
          src = doc-src;
          buildInputs = [lean-mdbook];
          buildCommand = ''
            mkdir $out
            # necessary for `additional-css`...?
            cp -r --no-preserve=mode $src/* .
            # overwrite stub .lean.md files
            cp -r ${generated-lean-markdown}/* .
            # build the book
            # NOTE: By this point, if we're using LeanInk/alectryon, the input
            # will have had all Lean code stripped and replaced with HTML.
            # As such, if you want to check that the Lean code is valid, make
            # sure to do so in the generated-lean-markdown derivation.
            mdbook build -d $out
          '';
        };
      in {
        packages = {
          inherit leanInk alectryon lean-mdbook generated-lean-markdown docs;
          default = docs;
        };

        devShells.default = mkShell {
          packages = [lean-all] ++ (builtins.attrValues self.packages.${system});
        };

        formatter = alejandra;
      });
}
