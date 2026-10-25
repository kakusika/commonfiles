<!-- Generated from tmtroot/readme.tmt. Edit that, then `tomet export .`. -->

# Common Files

The files that the repositories of the Tomet ecosystem share, kept once. A repository takes the ones it needs with [catasto](https://github.com/tomet-lang/fs-catasto), which pins each to a commit and a SHA-256, and `catasto check` (run by `sisho check`) says when a copy has been edited or has drifted.

Like `dotfiles`, the name is a convention: a repository of the common files of one person or one organisation, to be taken the same way.

## What is here

Everything that is handed out is under `base/`, laid out as it lands in a repository's root. Nothing under `base/` takes effect in this repository: `base/.github/workflows/` is not run here, and the files at this repository's own root (this readme, `tmtroot/`) are its own.

- the license texts the repositories carry.
- the editor settings.
- the `treefmt` setup the flakes use for `nix fmt`.
- direnv: `use flake`, and `scripts/` on the `PATH`.
- LF line endings, the Linguist settings, the documents `tomet export` writes marked generated, the Git LFS patterns. tomet keeps its own.
- builds a repository's packages and sends them to Cachix.
- builds the documents under `tmtroot/` with tomet-shelf and publishes them with GitHub Pages. Only a repository that publishes takes it.

## Taking a file

`base` is the root of the upstream, so a file is taken at the path it will have:

```bash
catasto upstream add commonfiles https://github.com/tomet-lang/commonfiles.git --root base
catasto add LICENSE-MIT --upstream commonfiles LICENSE-MIT
catasto add .editorconfig --upstream commonfiles .editorconfig
catasto add nix/formatter.nix --upstream commonfiles nix/formatter.nix
catasto add .github/workflows/nix-ci.yml --upstream commonfiles .github/workflows/nix-ci.yml
```

That declares the files in `catasto.ctmt`, copies them and writes `catasto.lock`. Commit the three. To take a newer version of one file later:

```bash
catasto sync --update --only LICENSE-MIT
```

A file here is never edited in the repository that took it: change it here, then take it again.

## The workflows

`nix-ci.yml` knows nothing about a repository except one thing, which the repository's flake says: a package called `ci`, which gathers what goes to Cachix.

```nix
packages.ci = pkgs.linkFarm "ci" [
  { name = "tomet-shelf"; path = tomet-shelf; }
  { name = "tomet-shelf-embedded-search"; path = tomet-shelf-embedded-search; }
];
```

The workflow runs `nix build .#ci`. The packages are in its closure, so Cachix gets them; the dev shell is not, so it is not built and not pushed. A flake without the package fails at that step and says so. The Cachix token is the secret `CACHIX_AUTH_TOKEN`; an organisation secret serves every repository.

What else a repository checks (tests, lints, generated files that must be fresh) is its own `.github/workflows/ci.yml`; nothing shared can know it.

## Adding a file

Only a file that is the same in every repository that has it belongs here, under `base/` at the path it should have in a repository. A file that differs by a name or a list (`.gitignore`, `default.config.tmt`) stays where it is.

