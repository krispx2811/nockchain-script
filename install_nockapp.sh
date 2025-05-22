#!/usr/bin/env bash
set -e

# Only thing you need to change:
PUBKEY="3KqWPYrkZxM2FjiJ6v1fdff87j9EqARRJifZp67u5jSTvFhqPWkcj37dkUHAMhfDUT5NUtC7Fzjymd6Kd377f4JNzf1ZEZb82wwERPLMw4KriHrrVnJumcWr4A7J2Yq1qtqQ"

# kill old session if it exists
tmux kill-session -t nock-miner 2>/dev/null || true

# show the binary
ls ~/nockchain/target/release/nockchain

# start miner in tmux
tmux new-session -d -s nock-miner "cd ~/nockchain && ./target/release/nockchain --mining-pubkey $PUBKEY --mine"
