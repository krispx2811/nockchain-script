#!/usr/bin/env bash
set -e

# Wallet public key (your miner identity)
PUBKEY="2qLyi7jNWFsYhFcUe25odS9uHRq9sjkvkcmyrJUWGPiAX1W3CWe3JqKFP3PTjWfNQrjjrckRqPAAwuAxtGDuD7nLomM46Wdw6mNoZdJwPa8gz77Au7Xffpu9R1NvrGCrsnm6"

# Name of your tmux session
SESSION="nock-miner-node"

# Clean and prep
mkdir -p ~/nockchain/miner-node
cd ~/nockchain/miner-node
rm -f nockchain.sock

# Kill old session if it exists
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Start a new tmux session that builds + runs nockchain, filtered by grep
tmux new-session -d -s "$SESSION" \
  'cd ~/nockchain && RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
   --npc-socket miner-node/nockchain.sock \
   --mining-pubkey '"$PUBKEY"' \
   --bind /ip4/0.0.0.0/udp/3006/quic-v1 \
   --mine | grep -aE "serf|panic|mining|candidate|validated"'

echo "✅ Miner started in tmux session: $SESSION"
echo "👉 Attach with:  tmux attach -t $SESSION"
