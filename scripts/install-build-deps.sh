#!/usr/bin/env bash
# Install apt packages, language toolchains, and any other system
# dependencies needed by `scripts/build-debs.sh` and the test runners.
#
# The template default is a no-op because the reference `build-debs.sh`
# only needs `dpkg-deb`, which is preinstalled on the GitHub-hosted
# `ubuntu-latest` runners. Real ports replace this script with the apt
# install / rustup / cargo / cmake / etc. commands their build needs.
#
# Contract: succeed when the runner is ready to build. Run early in CI;
# may invoke `sudo`. Idempotent reruns must succeed.
set -euo pipefail
exit 0
