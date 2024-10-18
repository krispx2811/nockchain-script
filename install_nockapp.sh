#!/bin/bash

# Define colors and gradients for an appealing output
RED='\033[38;5;196m'
ORANGE='\033[38;5;214m'
YELLOW='\033[38;5;226m'
GREEN='\033[38;5;118m'
CYAN='\033[38;5;44m'
BLUE='\033[38;5;27m'
MAGENTA='\033[38;5;200m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'  # No Color

# Spinner for smooth animations while waiting
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='🚀🌕🌍🌟'
    tput civis  # hide cursor
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for i in $(seq 0 ${#spinstr}); do
            echo -ne "${CYAN}${spinstr:i:1}${NC}"
            sleep $delay
            echo -ne "\r"
        done
    done
    tput cnorm  # show cursor
}

# Welcome message with gradient and emojis 🚀🎉
echo -e "${RED}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║             🚀 WELCOME TO THE NOCKAPP INSTALLER 🚀        ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║ ${ORANGE}The installation script designed with precision     ${RED}║"
echo "║ ${YELLOW}       and made for a superior experience.        ${RED}║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
sleep 1

# Prompt to begin
echo -e "${BLUE}Press [ENTER] to begin the ${BOLD}elegant installation${NC} ${CYAN}✨...${NC}"
read

# Step 1: Check if Cargo is installed 🚀
echo -e "${ORANGE}🚀 Checking for Cargo...${NC}"
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}⚠️  Cargo not found! Installing Rust and Cargo...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &> /dev/null &
    spinner
    source "$HOME/.cargo/env"
else
    echo -e "${GREEN}✔️  Cargo is already installed.${NC}"
fi
sleep 1

# Step 2: Install system dependencies 🛠️
echo -e "${YELLOW}🛠️  Installing system dependencies...${NC}"
sudo apt-get update -qq &
spinner
sudo apt-get install -y clang llvm libclang-dev &> /dev/null &  # Installing clang and libclang-dev
spinner
echo -e "${GREEN}✔️  Dependencies installed successfully!${NC}"
sleep 1

# Step 3: Set LIBCLANG_PATH for environment setup 🌍
echo -e "${CYAN}🌍 Configuring environment variables for libclang...${NC}"
export LIBCLANG_PATH=$(llvm-config --libdir)   # Auto-detect the correct libclang path
export CC=clang
echo -e "${GREEN}✔️  LIBCLANG_PATH set to: $LIBCLANG_PATH${NC}"
sleep 1

# Step 4: Check if the nockapp directory exists, and remove it if necessary
if [ -d "nockapp" ]; then
    echo -e "${YELLOW}⚠️  The 'nockapp' directory already exists. Removing it...${NC}"
    rm -rf nockapp
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔️  'nockapp' directory removed successfully.${NC}"
    else
        echo -e "${RED}⚠️  Error removing 'nockapp' directory. Please check your permissions.${NC}"
        exit 1
    fi
fi

# Step 5: Clone the GitHub repository 🌐
echo -e "${BLUE}🌐 Cloning the NockApp repository...${NC}"
git clone --depth=1 https://github.com/zorp-corp/nockapp.git &> /dev/null &
spinner
cd nockapp

# Enhanced Search for Cargo.toml 📂
CARGO_FILE=$(find . -name Cargo.toml | head -n 1)

# If Cargo.toml is found, navigate to the correct directory
if [ -n "$CARGO_FILE" ]; then
    DIR=$(dirname "$CARGO_FILE")
    echo -e "${GREEN}✔️  Found Cargo.toml in: $DIR${NC}"
    cd "$DIR"
else
    echo -e "${RED}⚠️  Error: Cargo.toml not found. Please check the repository structure.${NC}"
    exit 1
fi

# Step 6: Build the project using Cargo 🔨
echo -e "${YELLOW}🔨 Building NockApp...${NC}"
cargo build --release &> /dev/null &
spinner
echo -e "${GREEN}✔️  NockApp built successfully!${NC}"
sleep 1

# Step 7: Detect and run the correct binary 🚀
echo -e "${CYAN}🚀 Detecting the correct binary to run...${NC}"
if [ -f "./target/release/choo" ]; then
    echo -e "${GREEN}✔️  'choo' binary found. Running it now...${NC}"
    cargo run --release --bin choo hoon/lib/kernel.hoon &
elif [ -f "./target/release/http-app" ]; then
    echo -e "${YELLOW}⚠️  'choo' binary not found. Running 'http-app' without arguments...${NC}"
    cargo run --release --bin http-app &
else
    echo -e "${RED}⚠️  Neither 'choo' nor 'http-app' binaries found. Exiting.${NC}"
    exit 1
fi
spinner

# Final thank you message with style 🎉
echo -e "${MAGENTA}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  🎉 THANK YOU FOR INSTALLING AND RUNNING NOCKAPP! 🎉    ║"
echo "║  This process was brought to you with unmatched quality. ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║   🚀 Feel free to explore, contribute, and grow with us! 🚀  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Optional terminal bell sound to indicate completion 🎯
echo -en "\007"
