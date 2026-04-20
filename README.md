# Safelibs Port Template

This repository is the shared template for future `github.com/safelibs/port-*` repositories. A port repository keeps the original upstream implementation, a safe replacement implementation, CVE and dependent inventories, test harnesses, and Debian packaging metadata in one predictable layout.

The template is intentionally usable before a real port is filled in: placeholder tests pass when no test files exist, and the Debian package builder creates a placeholder payload if `safe/` has no packageable files. Real ports should replace those placeholders with source, data, tests, and package metadata for the library they are protecting.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `original/` | Upstream or original library source snapshot, or checked-in import/build instructions for obtaining that exact source. |
| `safe/` | Safe implementation source and any files that should be copied into the Debian package payload. |
| `tests/original/` | Shell tests that exercise the original implementation. `./test-original.sh` runs executable and non-executable `*.sh` files here with `bash`. |
| `tests/safe/` | Shell tests that exercise the safe implementation. `./test-safe.sh` runs executable and non-executable `*.sh` files here with `bash`. |
| `all_cves.json` | Inventory of known CVEs for the original package or project. |
| `dependents.json` | Inventory of dependent packages, projects, or applications used to evaluate compatibility and blast radius. |
| `relevant_cves.json` | CVEs selected as relevant to the safe port, with the criteria used for selection. |
| `test-original.sh` | Root test entrypoint for the original implementation. It delegates to `scripts/run-tests.sh original`. |
| `test-safe.sh` | Root test entrypoint for the safe implementation. It delegates to `scripts/run-tests.sh safe`. |
| `packaging/package.env` | Debian package metadata that every real port must update before release. |
| `scripts/build-deb.sh` | Local and CI Debian package builder. It validates `packaging/package.env`, copies `safe/` into the configured install prefix, and writes a `.deb` under `dist/`. |
| `.github/workflows/ci-release.yml` | GitHub Actions workflow that validates, tests, builds `.deb` artifacts, uploads them, and creates GitHub Releases for pushed commits. |

## Quick Start

1. Create a new `safelibs/port-*` repository from this template.
2. Fill `original/` with the upstream source snapshot or precise import/build instructions for the original implementation.
3. Fill `safe/` with the safe implementation and packageable files.
4. Replace the placeholder data in `all_cves.json`, `dependents.json`, and `relevant_cves.json`.
5. Add tests under `tests/original/` and `tests/safe/`, or replace `test-original.sh` and `test-safe.sh` if the port needs a different harness.
6. Update `packaging/package.env` for the port.
7. Run local validation and package build commands before pushing to `main`.

If a future port already contains prepared source snapshots, CVE data, dependent inventories, or test harnesses, consume and update those artifacts in place. Do not rediscover, refetch, or regenerate them from scratch unless the existing artifact is missing or known to be wrong.

## Local Verification

Run these commands from the repository root:

```sh
bash scripts/validate-template.sh
./test-original.sh
./test-safe.sh
bash scripts/build-deb.sh
```

For a clean package-build check, remove previous outputs first:

```sh
rm -rf build dist
bash scripts/build-deb.sh
```

The root test scripts pass when there are no `*.sh` files under `tests/original/` or `tests/safe/`. That behavior keeps the template bootstrap-friendly, but real ports should add meaningful tests in those directories or replace the root scripts with port-specific test entrypoints.

## Packaging Metadata

Every real port must update `packaging/package.env` before publishing releases:

| Field | Required update |
| --- | --- |
| `DEB_PACKAGE` | Debian package name for the safe library. Use lowercase Debian naming, such as `safelibs-port-example`. |
| `DEB_VERSION` | Base upstream or port version. `scripts/build-deb.sh` appends `+git.<commit-sha>` during builds. |
| `DEB_ARCHITECTURE` | Debian architecture, or `auto` to use `dpkg --print-architecture`. |
| `DEB_MAINTAINER` | Real maintainer contact for the port. Replace the template `.invalid` address. |
| `DEB_SECTION` | Debian section, usually `libs` for library ports. |
| `DEB_PRIORITY` | Debian priority, usually `optional`. |
| `DEB_DESCRIPTION` | Short package description for the safe library artifacts. |
| `DEB_INSTALL_PREFIX` | Absolute install path where files from `safe/` are placed in the package. Do not use `/`. |
| `DEB_DEPENDS` | Comma-separated Debian dependency list, or an empty string if there are no package dependencies. |

The package builder rejects unsupported variables, command substitution, process substitution, empty required fields, invalid package names, and non-absolute install prefixes.

## CI And GitHub Releases

`.github/workflows/ci-release.yml` runs on pushes to `main` and on manual `workflow_dispatch`. For each normal pushed commit on `main`, CI:

1. Runs `bash scripts/validate-template.sh`.
2. Runs `./test-original.sh` and `./test-safe.sh`.
3. Builds one Debian package with `bash scripts/build-deb.sh`.
4. Uploads the `.deb` files as GitHub Actions artifacts.
5. Creates or updates a GitHub Release tagged `commit-<sha>` with the `.deb` for that commit.

Manual workflow runs validate and build the current checked-out commit, but release publishing only runs for push events.

The one-time initial publication push of this template may include older scaffold commits that predate the completed template contract. The workflow is expected to skip only those incomplete bootstrap commits during the initial branch creation push. The pushed head commit must still pass validation, run both test entrypoints, build a `.deb`, upload the artifact, and publish its `commit-<sha>` GitHub Release.

## Guides

- [Porting guide](docs/PORTING.md)
- [Publishing guide](docs/PUBLISHING.md)
