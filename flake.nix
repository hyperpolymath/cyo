# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2024-2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Nix fallback for the cyo dev environment (Guix is primary; see guix.scm).
# Retained per standards#102 rule 3 (KEEP+DEP): this flake is the sole
# source of `reuse` (the SPDX/REUSE-spec linter), which the Guix
# manifest does not carry. Remove only once `reuse` is available via Guix.
#   nix develop
{
  description = "cyo — choose-your-own-adventure for your craft (dev shell)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "cyo";
          packages = with pkgs; [
            bashInteractive
            coreutils
            asciidoctor
            bat
            shellcheck
            reuse
          ];
        };
      });
}
