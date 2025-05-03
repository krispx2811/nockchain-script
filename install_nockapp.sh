#!/usr/bin/env bash
set -euo pipefail

# 0) Prerequisites
for cmd in git make cargo; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed." >&2
    exit 1
  fi
done

# 1) Prompt for mining pubkey & ports
DEFAULT_PUBKEY="EHmKL2U3vXfS5GYAY5aVnGdukfDWwvkQPCZXnjvZVShsSQi3UAuA4tQQpVwGJMzc9FfpTY8pLDkqhBGfWutiF4prrCktUH9oAWJxkXQBzAavKDc95NR3DjmYwnnw8GuugnK"
read -rp "Enter your mining pubkey (or leave blank for default): " MINING_PUBKEY
MINING_PUBKEY="${MINING_PUBKEY:-$DEFAULT_PUBKEY}"

read -rp "Enter leader UDP port to peer to [3005]: " LEADER_PORT
LEADER_PORT="${LEADER_PORT:-3005}"

read -rp "Enter follower UDP port [3006]: " FOLLOWER_PORT
FOLLOWER_PORT="${FOLLOWER_PORT:-3006}"

# 2) Fresh clone nockchain
echo "🌱 Removing any old nockchain/ and cloning fresh…"
rm -rf nockchain
git clone https://github.com/zorp-corp/nockchain.git

# 3) Install choo & build inside nockchain/
pushd nockchain >/dev/null

echo "🔧 Installing choo via Makefile…"
make install-choo

echo "🛠️  Building Hoon artifacts…"
make build-hoon-all

echo "🛠️  Building Rust binary…"
make build

popd >/dev/null

# 4) Launch follower node
echo "🚀 Starting follower on UDP port ${FOLLOWER_PORT}, peering to leader:${LEADER_PORT}"
pushd nockchain >/dev/null

RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
  --fakenet \
  --genesis-watcher \
  --npc-socket nockchain.sock \
  --mining-pubkey "${MINING_PUBKEY}" \
  --bind "/ip4/0.0.0.0/udp/${FOLLOWER_PORT}/quic-v1" \
  --peer "/ip4/127.0.0.1/udp/${LEADER_PORT}/quic-v1" \
  --new-peer-id \
  --no-default-peers

popd >/dev/null
