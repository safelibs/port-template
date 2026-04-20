# Porting Guide

Use this checklist when creating a new `safelibs/port-*` repository from this template. Keep changes focused on the port being created, and update prepared artifacts in place when they already exist.

## Port Checklist

1. Choose or create a new `safelibs/port-*` repository from this template.
2. Fill `original/` with the upstream source snapshot for the original implementation, or with precise import/build instructions for obtaining that exact source.
3. Fill `safe/` with the safe implementation and any files that should be packaged.
4. Replace the placeholder CVE and dependent data in `all_cves.json`, `dependents.json`, and `relevant_cves.json`.
5. Add original implementation tests under `tests/original/`, or replace `test-original.sh` with a port-specific entrypoint.
6. Add safe implementation tests under `tests/safe/`, or replace `test-safe.sh` with a port-specific entrypoint.
7. Update `packaging/package.env` with the Debian package metadata for the port.
8. Run local validation, tests, and package build commands.
9. Push to `main`.
10. Inspect GitHub Actions artifacts and GitHub Releases for the pushed commit.

## Consuming Existing Artifacts

Future ports may already have checked-in source snapshots, CVE data, dependent inventories, or test harnesses prepared by earlier workflow phases. Treat those artifacts as inputs:

- If `original/` already contains the needed upstream snapshot or import instructions, use it as the source of truth and update it only when the selected upstream version changes.
- If `all_cves.json`, `dependents.json`, or `relevant_cves.json` already contains prepared data, preserve useful entries and edit the files in place. Do not recollect the whole inventory just because the port is moving into this template.
- If `tests/original/`, `tests/safe/`, `test-original.sh`, or `test-safe.sh` already contains a working harness, keep it and adapt it to the final layout.
- If an artifact is missing, incomplete, or known to be stale, document the correction in the commit that updates it.

## Source Layout

Put the upstream or original implementation under `original/`. A source snapshot is preferred when it is small enough and legally appropriate to check in. If the source should not be committed directly, keep deterministic import instructions in `original/README.md` or adjacent scripts so maintainers can reproduce the exact original input.

Put the safe implementation under `safe/`. `scripts/build-deb.sh` copies files from `safe/` into the package install prefix while excluding `.git`, `build`, `dist`, `.gitkeep`, and `README.md`. Add the packageable library artifacts or build outputs that should land in the `.deb`.

## CVE And Dependent Data

Replace the placeholders with port-specific data:

- `all_cves.json`: full CVE inventory considered for the original package or project.
- `relevant_cves.json`: subset of CVEs relevant to the safe implementation, including the selection criteria.
- `dependents.json`: dependent packages, projects, or applications used to evaluate compatibility and risk.

Keep the files valid JSON. The template validator runs `python3 -m json.tool` on each file.

## Tests

The default root scripts delegate to `scripts/run-tests.sh`, which runs every `*.sh` file in the matching test directory with `bash`.

- Add original behavior tests under `tests/original/`.
- Add safe implementation tests under `tests/safe/`.
- Keep tests deterministic and runnable from the repository root.
- Replace `test-original.sh` or `test-safe.sh` only when a port needs a different test runner.

The placeholder harness exits successfully when no tests exist. That is only for template bootstrap; a real port should include tests that prove both the original behavior and safe implementation behavior needed by the port.

## Packaging

Update `packaging/package.env` before publishing:

- `DEB_PACKAGE`: package name, for example `safelibs-port-example`.
- `DEB_VERSION`: base version; the builder appends `+git.<commit-sha>`.
- `DEB_ARCHITECTURE`: Debian architecture or `auto`.
- `DEB_MAINTAINER`: real maintainer contact.
- `DEB_SECTION`: package section, usually `libs`.
- `DEB_PRIORITY`: package priority, usually `optional`.
- `DEB_DESCRIPTION`: short package description.
- `DEB_INSTALL_PREFIX`: absolute install path for copied `safe/` files.
- `DEB_DEPENDS`: comma-separated dependencies or an empty string.

Build locally before pushing:

```sh
rm -rf build dist
bash scripts/build-deb.sh
```

The resulting package is written to `dist/`.

## Local Verification

Run the same checks the template expects CI to run:

```sh
bash scripts/validate-template.sh
./test-original.sh
./test-safe.sh
rm -rf build dist
bash scripts/build-deb.sh
```

Fix validation, test, or package build failures before pushing to `main`.

## Push And Inspect

Push completed port work to `main`. The CI workflow runs validation, tests, and package building for pushed commits. For each normal pushed commit, it uploads `.deb` artifacts and creates or updates a GitHub Release named `commit-<sha>`.

After pushing, inspect:

- The latest run of `.github/workflows/ci-release.yml`.
- The uploaded `.deb` artifact for the workflow run.
- The GitHub Release for `commit-<sha>`.
