#!/usr/bin/env bash
set -e

# ← ONLY change this:
PUBKEY="3KqWPYrkZxM2FjiJ6v1fdff87j9EqARRJifZp67u5jSTvFhqPWkcj37dkUHAMhfDUT5NUtC7Fzjymd6Kd377f4JNzf1ZEZb82wwERPLMw4KriHrrVnJumcWr4A7J2Yq1qtqQ"

# remove old session
tmux kill-session -t nock-miner 2>/dev/null || true

# verify binary exists
ls ~/nockchain/target/release/nockchain

# launch in tmux
tmux new-session -d -s nock-miner \
  "cd ~/nockchain && ./target/release/nockchain --mining-pubkey $PUBKEY --mine"

echo "✅ Started! Attach to it with:"
echo "    tmux attach -t $SESSION"
