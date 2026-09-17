# homebrew-recipe-modflow6

[![tests](https://github.com/MODFLOW-ORG/homebrew-recipe-modflow6/actions/workflows/tests.yml/badge.svg)](https://github.com/MODFLOW-ORG/homebrew-recipe-modflow6/actions/workflows/tests.yml)

Homebrew formulae for MODFLOW 6.

| Formula | Description |
| --- | --- |
| `modflow6` | Serial build of MODFLOW 6 (`mf6`, `zbud6`, `mf5to6`, and `libmf6`) |

## Install

```sh
brew tap modflow-org/recipe-modflow6
brew install modflow-org/recipe-modflow6/modflow6
```

Use `--HEAD` to build the `develop` branch.

## Test

```sh
brew test modflow-org/recipe-modflow6/modflow6
brew audit --strict --online modflow-org/recipe-modflow6/modflow6
```

The `tests` workflow builds and tests every formula on macOS and Linux for
pushes, pull requests, and a weekly scheduled run. The scheduled run also
reports formulae that are behind the latest upstream release.
