# NIX SHELL that installs all possible requirements for CEMACS and enable all possible custom options
{ pkgs ? import <nixpkgs> {}, ... }:
pkgs.mkShell {
  name = "cemacs-impure";

  packages = with pkgs; [
    emacs
  ];
}
