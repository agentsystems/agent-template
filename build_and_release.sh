#!/usr/bin/env bash
# Wrapper for the shared build helper.
# ---------------------------------------------------------------------------
# This template intentionally DOES NOT hard-code a registry namespace because
# each agent derived from this repo should publish under **your own** Docker Hub
# username / organisation.
#
# Usage examples:
#   ./build_and_release.sh --image johndoe/echo-agent:0.1.0            # local build
#   ./build_and_release.sh --image johndoe/echo-agent --version 1.0.0 \  
#                              --push                                   # push to Hub
# ---------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  echo "\nError: you must supply --image <your_dockerhub_namespace>/<agent_name>"
  echo "Example: ./build_and_release.sh --image johndoe/echo-agent --version 0.1.0\n"
  exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/../agentsystems-build-tools/release_common.sh" "$@"
