# rxb06/tap

Homebrew formulae for [Credactor](https://github.com/rxb06/credactor).

## Install

```bash
brew install rxb06/tap/credactor
```

Or tap first, then install by bare name:

```bash
brew tap rxb06/tap
brew install credactor
```

Verify:

```bash
credactor --version
credactor --dry-run .
```

## What you get

Credactor and its optional `[encoding]` extra (`charset-normalizer`), installed
into their own virtualenv against `python@3.13`. Nothing is added to your system
Python, and nothing else on your machine changes.

The `[encoding]` extra is included deliberately: without it, non-UTF-8 files are
read as Latin-1 and their credentials can be missed. Credactor warns when it
falls back, but the finding is still lost, so the extra ships by default here.

## Upgrading

```bash
brew update && brew upgrade credactor
```

A scheduled job checks PyPI daily and opens a pull request against this tap when
a new Credactor release appears, so the formula tracks upstream without manual
edits.

## Other ways to install Credactor

```bash
uv tool install credactor      # isolated, binary on PATH
pipx install credactor         # same idea
pip install credactor          # into the active environment
```

See the [Credactor repository](https://github.com/rxb06/credactor) for the
manual, CI integration guide and pre-commit hook.

## Licence

The formulae here are released under the same terms as Homebrew itself.
Credactor is licensed Apache-2.0.
