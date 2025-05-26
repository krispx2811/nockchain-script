#!/usr/bin/env bash
set -e

PUBKEY="2qLyi7jNWFsYhFcUe25odS9uHRq9sjkvkcmyrJUWGPiAX1W3CWe3JqKFP3PTjWfNQrjjrckRqPAAwuAxtGDuD7nLomM46Wdw6mNoZdJwPa8gz77Au7Xffpu9R1NvrGCrsnm6"
SESSION="nock-miner-node"
LOG_FILE="$HOME/nockchain/miner-node/miner.log"

# Clean start
mkdir -p ~/nockchain/miner-node
cd ~/nockchain/miner-node
rm -f nockchain.sock "$LOG_FILE"

# Kill old session if exists
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Start new tmux session with miner
tmux new-session -d -s "$SESSION" "cd ~/nockchain && RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
  --npc-socket miner-node/nockchain.sock \
  --mining-pubkey '$PUBKEY' \
  --bind /ip4/0.0.0.0/udp/3006/quic-v1 \
  --mine | tee '$LOG_FILE'"

# Add second window for filtered logs
tmux new-window -t "$SESSION" -n logs "tail -f '$LOG_FILE' | grep -aE 'serf|panic|mining|candidate|validated'"

echo "✅ Miner started in tmux session: $SESSION"
echo "👉 Attach with: tmux attach -t $SESSION"
