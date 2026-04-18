# moonfin-flake

Standalone Nix flake packaging for Moonfin built from source with
`flutter341.buildFlutterApplication` from nixpkgs unstable.

## Usage

Run Moonfin:

```bash
nix run .
```

Build package:

```bash
nix build .#moonfin
```

## Automated updates

The workflow at `.github/workflows/update-moonfin.yml` runs hourly and commits
directly to the default branch when a new Moonfin release is available.
