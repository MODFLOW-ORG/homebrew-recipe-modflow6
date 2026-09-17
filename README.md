# homebrew-recipe

Homebrew formulae for MODFLOW 6.

| Formula | Description |
| --- | --- |
| `modflow6` | Serial build of MODFLOW 6 (`mf6`, `zbud6`, `mf5to6`, and `libmf6`) |

## Install

Tap this repository and install the formula.

```sh
brew tap <user>/recipe https://github.com/<user>/homebrew-recipe
brew install modflow6
```

To build from a local clone instead, tap the clone path.

```sh
brew tap <user>/recipe /path/to/homebrew-recipe
brew install modflow6
```

Use `--HEAD` to build the `develop` branch.

## Test

```sh
brew test modflow6
brew audit --strict modflow6
```
