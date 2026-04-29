# Safelibs Port Template

This repository is the shared template for `github.com/safelibs/port-*` repositories. A port keeps the original upstream implementation, a safe replacement implementation, CVE and dependent inventories, test harnesses, and Debian packaging metadata in one predictable layout. CI is a fixed sequence of hook scripts under `scripts/`; ports override the hooks they need without touching the workflow file.

The template is intentionally usable before a real port is filled in: placeholder tests pass when no test files exist, and the Debian package builder writes a placeholder payload if `safe/` has no packageable files. Real ports replace those placeholders with source, data, tests, and package metadata for the library they are protecting.

The full contract — what each script must do, the order CI runs them in, and which behaviors are required vs. defaulted — lives in [AGENTS.md](AGENTS.md). Read that before adding a new port or modifying the workflow.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `original/` | Upstream or original library source snapshot, or checked-in import/build instructions for obtaining that exact source. |
| `safe/` | Safe implementation source and any files that should be copied into the Debian package payload. |
| `tests/upstream/` | Shell tests that exercise the original implementation. `scripts/run-upstream-tests.sh` runs every `*.sh` file here with `bash`. |
| `tests/port/` | Shell tests that exercise the safe implementation. `scripts/run-port-tests.sh` runs every `*.sh` file here with `bash`. |
| `all_cves.json` | Inventory of known CVEs for the original package or project. |
| `dependents.json` | Inventory of dependent packages, projects, or applications used to evaluate compatibility and blast radius. |
| `relevant_cves.json` | CVEs selected as relevant to the safe port, with the criteria used for selection. |
| `packaging/package.env` | Debian package metadata plus `SAFELIBS_LIBRARY` (the validator manifest identifier). |
| `scripts/install-build-deps.sh` | Hook: install apt packages, language toolchains, system deps. Template default reads `safe/rust-toolchain.toml` (falls back to stable) and installs rustup; ports override when more is needed. |
| `scripts/check-layout.sh` | Hook: lint the repository layout, enforce `SAFELIBS_LIBRARY` matches the repo name suffix, and refuse hardcoded `/home/<user>/safelibs/port-*` paths under `safe/` and `.cargo/`. |
| `scripts/build-debs.sh` | Hook: produce one or more `.deb` files under `dist/`. |
| `scripts/run-upstream-tests.sh` | Hook: run upstream's regression tests against the built `.deb`s. |
| `scripts/run-port-tests.sh` | Hook: run port-authored tests for the safe implementation. |
| `scripts/run-validation-tests.sh` | Hook: run the [safelibs/validator](https://github.com/safelibs/validator) test matrix in `port-04-test` mode against `dist/`. |
| `scripts/run-tests.sh` | Internal helper that powers the upstream/port test runners. |
| `scripts/lib/build-deb-common.sh` | Bash helper for port-specific `build-debs.sh` overrides (rust env, dist dir, changelog stamping, dpkg-buildpackage runner). |
| `scripts/lib/build_port_lock.py` | Internal helper for `run-validation-tests.sh`. |
| `.github/workflows/ci-release.yml` | GitHub Actions workflow that runs the hook sequence and publishes a `build-<short-sha>` GitHub Release. |
| `AGENTS.md` | Canonical contract. Required reading before changing scripts, layout, or CI. |
| `CLAUDE.md` | Pointer to `AGENTS.md` for Claude Code. |

## Quick Start

1. Create a new `safelibs/port-*` repository from this template.
2. Fill `original/` with the upstream source snapshot, or precise import/build instructions.
3. Fill `safe/` with the safe implementation and packageable files.
4. Replace the placeholder data in `all_cves.json`, `dependents.json`, and `relevant_cves.json`.
5. Add tests under `tests/upstream/` and `tests/port/`, or replace the matching script with a port-specific runner.
6. Update `packaging/package.env` for the port — including `SAFELIBS_LIBRARY` if the port has a validator manifest entry.
7. Override any of the hook scripts under `scripts/` whose template default does not fit the port (typically `install-build-deps.sh` and `build-debs.sh`).
8. Run local validation and package build commands before pushing to `main`.

If a future port already contains prepared source snapshots, CVE data, dependent inventories, or test harnesses, consume and update those artifacts in place. Do not rediscover, refetch, or regenerate them from scratch unless the existing artifact is missing or known to be wrong.

## Local Verification

Run these from the repository root:

```sh
bash scripts/install-build-deps.sh
bash scripts/check-layout.sh
rm -rf build dist
bash scripts/build-debs.sh
bash scripts/run-upstream-tests.sh
bash scripts/run-port-tests.sh
bash scripts/run-validation-tests.sh
```

`run-validation-tests.sh` clones `safelibs/validator` into `.work/validator` on first use. To reuse a local checkout, set `SAFELIBS_VALIDATOR_DIR=/path/to/validator`. A library that has no entry in the validator manifest (the template itself, an in-progress port) is a soft success: the script logs a skip and exits 0.

## Packaging Metadata

The only field every port must set in `packaging/package.env`:

| Field | Required update |
| --- | --- |
| `SAFELIBS_LIBRARY` | Library identifier matching the validator manifest **and** the repo name suffix (`safelibs/port-<SAFELIBS_LIBRARY>`). `scripts/check-layout.sh` enforces both. |

The template's reference `scripts/build-debs.sh` *also* consumes a set of `DEB_*` fields (`DEB_PACKAGE`, `DEB_VERSION`, `DEB_ARCHITECTURE`, `DEB_MAINTAINER`, `DEB_SECTION`, `DEB_PRIORITY`, `DEB_DESCRIPTION`, `DEB_INSTALL_PREFIX`, `DEB_DEPENDS`) for its self-contained payload-copy build. Real ports override `build-debs.sh` (typically with `dpkg-buildpackage` rooted in `safe/debian/`) and can drop the `DEB_*` fields from `packaging/package.env` entirely.

## CI And GitHub Releases

`.github/workflows/ci-release.yml` runs on pushes to `main` and on manual `workflow_dispatch`. For each normal pushed commit on `main`, CI runs the hook sequence:

1. `scripts/install-build-deps.sh`
2. `scripts/check-layout.sh`
3. `scripts/build-debs.sh`
4. `scripts/run-upstream-tests.sh`
5. `scripts/run-port-tests.sh`
6. `scripts/run-validation-tests.sh`

It then uploads every `dist/*.deb` as a GitHub Actions artifact and creates or updates a GitHub Release tagged `build-<short-sha>` with those `.deb` files.

Manual workflow runs execute the same hook sequence, but release publishing only fires for `push` events.

## Guides

- [Porting guide](docs/PORTING.md)
- [Publishing guide](docs/PUBLISHING.md)
- [AGENTS.md](AGENTS.md) — canonical contract for the template
