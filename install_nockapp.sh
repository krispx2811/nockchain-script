#!/usr/bin/env bash
set -e

# 0) Check prerequisites
for cmd in git make cargo; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: '$cmd' is not installed. Please install it first." >&2
    exit 1
  fi
done

# 1) Ask for your mining pubkey (or use a default)
DEFAULT_PUBKEY="EHmKL2U3vXfS5GYAY5aVnGdukfDWwvkQPCZXnjvZVShsSQi3UAuA4tQQpVwGJMzc9FfpTY8pLDkqhBGfWutiF4prrCktUH9oAWJxkXQBzAavKDc95NR3DjmYwnnw8GuugnK"
read -p "Enter your mining pubkey (leave blank for default): " MINING_PUBKEY
MINING_PUBKEY=${MINING_PUBKEY:-$DEFAULT_PUBKEY}

# 2) Ask for UDP ports
read -p "Enter leader UDP port [3005]: " LEADER_PORT
LEADER_PORT=${LEADER_PORT:-3005}
read -p "Enter follower UDP port [3006]: " FOLLOWER_PORT
FOLLOWER_PORT=${FOLLOWER_PORT:-3006}

# 3) Clone or update Nockchain
if [ -d nockchain ]; then
  echo "Updating existing nockchain repo…"
  cd nockchain && git pull && cd ..
else
  echo "Cloning nockchain repo…"
  git clone https://github.com/zorp-corp/nockchain.git
fi

# 4) Build Nockchain
echo "Building nockchain…"
cd nockchain
make build-hoon-all
make build
cd ..

# 5) Start leader in background
echo "Starting leader on UDP port $LEADER_PORT…"
cd nockchain
RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
  --fakenet \
  --genesis-leader \
  --npc-socket nockchain.sock \
  --mining-pubkey "$MINING_PUBKEY" \
  --bind /ip4/0.0.0.0/udp/$LEADER_PORT/quic-v1 \
  --new-peer-id \
  --no-default-peers \
  > ../leader.log 2>&1 &
PID_LEADER=$!
cd ..

# give it a moment to bind
sleep 2

# 6) Start follower in background
echo "Starting follower on UDP port $FOLLOWER_PORT (peering to leader at port $LEADER_PORT)…"
cd nockchain
RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
  --fakenet \
  --genesis-watcher \
  --npc-socket nockchain.sock \
  --mining-pubkey "$MINING_PUBKEY" \
  --bind /ip4/0.0.0.0/udp/$FOLLOWER_PORT/quic-v1 \
  --peer /ip4/127.0.0.1/udp/$LEADER_PORT/quic-v1 \
  --new-peer-id \
  --no-default-peers \
  > ../follower.log 2>&1 &
PID_FOLLOWER=$!
cd ..

# 7) Summary
echo
echo "✅ Leader started (PID $PID_LEADER), logs → leader.log"
echo "✅ Follower started (PID $PID_FOLLOWER), logs → follower.log"
echo "Done."
