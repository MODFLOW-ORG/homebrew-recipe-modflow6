# homebrew-recipe-modflow6

[![tests](https://github.com/MODFLOW-ORG/homebrew-recipe-modflow6/actions/workflows/tests.yml/badge.svg)](https://github.com/MODFLOW-ORG/homebrew-recipe-modflow6/actions/workflows/tests.yml)

Homebrew formulae for MODFLOW 6.

| Formula | Description |
| --- | --- |
| `modflow6` | Serial build of MODFLOW 6 (`mf6`, `zbud6`, `mf5to6`, and `libmf6`) |
| `modflow6-extended` | Extended build of MODFLOW 6 with MPI, PETSc, and NetCDF (`mf6`, `zbud6`, and `libmf6`) |
| `petsc@3.22` | PETSc 3.22.2, the version the MODFLOW 6 extended build requires |

`modflow6` and `modflow6-extended` both install `mf6`, so only one can be
installed at a time.

## Install

```sh
brew tap modflow-org/recipe-modflow6
brew install modflow-org/recipe-modflow6/modflow6
```

For the extended build, which compiles PETSc from source on first install:

```sh
brew install modflow-org/recipe-modflow6/modflow6-extended
mpiexec -n 2 mf6 -p
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
