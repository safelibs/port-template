# Safelibs Port Template

This repository is the shared Safelibs template for future `port-*` repositories. Each port can replace these placeholders with the source, metadata, tests, and packaging needed for one safe library project.

## Layout

- `original/`: upstream or original library implementation, imported source snapshot, or build instructions.
- `safe/`: safe implementation and any source files needed to build or package the safe library.
- `tests/original/`: tests that exercise the original implementation.
- `tests/safe/`: tests that exercise the safe implementation.
- `all_cves.json`: placeholder inventory for known CVEs for the package.
- `relevant_cves.json`: placeholder inventory for CVEs selected as relevant to the port.
- `dependents.json`: placeholder inventory for dependent packages or projects.

Detailed usage guidance will be added by the docs and metadata phase.
