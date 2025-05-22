#!/usr/bin/env bash
set -e

# ← ONLY change this:
PUBKEY="2qLyi7jNWFsYhFcUe25odS9uHRq9sjkvkcmyrJUWGPiAX1W3CWe3JqKFP3PTjWfNQrjjrckRqPAAwuAxtGDuD7nLomM46Wdw6mNoZdJwPa8gz77Au7Xffpu9R1NvrGCrsnm6"

# name of your tmux session
SESSION="nock-miner"

# kill old session if it exists
tmux kill-session -t "$SESSION" 2>/dev/null || true

# verify the binary is there
ls ~/nockchain/target/release/nockchain

# launch miner in tmux
tmux new-session -d -s "$SESSION" \
  "cd ~/nockchain && ./target/release/nockchain --mining-pubkey $PUBKEY --mine"

echo "✅ Started! Attach to it with:"
echo "    tmux attach -t $SESSION"
