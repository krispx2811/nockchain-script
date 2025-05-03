#!/usr/bin/env bash
set -euo pipefail

# 0) Prerequisites
for cmd in git make cargo; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed." >&2
    exit 1
  fi
done

# 1) Fresh clone Nockchain
echo "🌱 Cloning fresh nockchain repo…"
rm -rf nockchain
git clone https://github.com/zorp-corp/nockchain.git

# 2) Enter repo
cd nockchain

# 3) Install Hoon compiler
echo "🔧 Installing choo (Hoon compiler)…"
make install-choo

# 4) Build all Hoon artifacts and the Rust binary
echo "🛠️  Building Hoon artifacts…"
make build-hoon-all

echo "🛠️  Building Rust binary…"
make build

# 5) Launch follower only
echo "🚀 Starting follower only (using Makefile’s default ports)…"
make run-nockchain-follower
