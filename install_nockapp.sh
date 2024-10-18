#!/bin/bash

# Define colors for a sleek look
PINK='\033[38;5;205m'
ORANGE='\033[38;5;214m'
RED='\033[38;5;196m'
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
            echo -ne "${PINK}${spinstr:i:1}${NC}"
            sleep $delay
            echo -ne "\r"
        done
    done
    tput cnorm  # show cursor
}

# Welcome message with a sleek, minimal look 🚀🎉
echo -e "${PINK}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║             🚀 WELCOME TO THE NOCKAPP INSTALLER 🚀        ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║         The installation script designed with care        ║"
echo "║            and made for a superior experience.            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
sleep 1

# Prompt to begin
echo -e "${ORANGE}Press [ENTER] to begin the elegant installation ✨...${NC}"
read

# Step 1: Check if Cargo is installed 🚀
echo -e "${ORANGE}🚀 Checking for Cargo...${NC}"
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}⚠️  Cargo not found! Installing Rust and Cargo...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &
    spinner
    source "$HOME/.cargo/env"
else
    echo -e "${PINK}✔️  Cargo is already installed.${NC}"
fi
sleep 1

# Step 2: Install system dependencies 🛠️
echo -e "${ORANGE}🛠️  Installing system dependencies...${NC}"
sudo apt-get update -qq &
spinner
sudo apt-get install -y clang llvm libclang-dev &  # Installing clang and libclang-dev
spinner
echo -e "${PINK}✔️  Dependencies installed successfully!${NC}"
sleep 1

# Step 3: Set LIBCLANG_PATH for environment setup 🌍
echo -e "${ORANGE}🌍 Configuring environment variables for libclang...${NC}"
export LIBCLANG_PATH=$(llvm-config --libdir)   # Auto-detect the correct libclang path
export CC=clang
echo -e "${PINK}✔️  LIBCLANG_PATH set to: $LIBCLANG_PATH${NC}"
sleep 1

# Step 4: Check if the nockapp directory exists, and remove it if necessary
if [ -d "nockapp" ]; then
    echo -e "${ORANGE}⚠️  The 'nockapp' directory already exists. Removing it...${NC}"
    rm -rf nockapp
    if [ $? -eq 0 ]; then
        echo -e "${PINK}✔️  'nockapp' directory removed successfully.${NC}"
    else
        echo -e "${RED}⚠️  Error removing 'nockapp' directory. Please check your permissions.${NC}"
        exit 1
    fi
fi

# Step 5: Clone the GitHub repository 🌐
echo -e "${ORANGE}🌐 Cloning the NockApp repository...${NC}"
git clone --depth=1 https://github.com/zorp-corp/nockapp.git
if [ $? -ne 0 ]; then
    echo -e "${RED}⚠️  Failed to clone the repository. Please check the URL.${NC}"
    exit 1
fi
cd nockapp

# Enhanced Search for Cargo.toml 📂
CARGO_FILE=$(find . -name Cargo.toml | head -n 1)

# If Cargo.toml is found, navigate to the correct directory
if [ -n "$CARGO_FILE" ]; then
    DIR=$(dirname "$CARGO_FILE")
    echo -e "${PINK}✔️  Found Cargo.toml in: $DIR${NC}"
    cd "$DIR"
else
    echo -e "${RED}⚠️  Error: Cargo.toml not found. Please check the repository structure.${NC}"
    exit 1
fi

# Step 6: Build the project using Cargo 🔨
echo -e "${ORANGE}🔨 Building NockApp...${NC}"
cargo build --release
if [ $? -ne 0 ]; then
    echo -e "${RED}⚠️  Build failed. Please check the error messages above.${NC}"
    exit 1
fi
echo -e "${PINK}✔️  NockApp built successfully!${NC}"
sleep 1

# Step 7: Detect and run the correct binary 🚀
echo -e "${ORANGE}🚀 Detecting the correct binary to run...${NC}"
if [ -d "choo" ]; then
    echo -e "${PINK}✔️  'choo' directory found. Running kernel program from it...${NC}"
    cd choo
    echo -e "${PINK}Executing: cargo run --release hoon/lib/kernel.hoon${NC}"
    cargo run --release hoon/lib/kernel.hoon
elif [ -f "./target/release/http-app" ]; then
    echo -e "${ORANGE}⚠️  'choo' directory not found. Running 'http-app' binary...${NC}"
    cargo run --release --bin http-app
else
    echo -e "${RED}⚠️  Neither 'choo' directory nor 'http-app' binary found. Checking possible errors in the build...${NC}"
    echo -e "${ORANGE}🔍 Checking if the build produced any binaries in ./target/release...${NC}"
    ls ./target/release
    exit 1
fi

# Final thank you message with style 🎉
echo -e "${PINK}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  🎉 THANK YOU FOR INSTALLING AND RUNNING NOCKAPP! 🎉    ║"
echo "║  This process was brought to you with unmatched quality. ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║   🚀 Feel free to explore, contribute, and grow with us! 🚀  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Optional terminal bell sound to indicate completion 🎯
echo -en "\007"
