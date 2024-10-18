#!/bin/bash

# Define colors for professional output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Spinner for smooth animations while waiting
spinner() {
    local pid=$!
    local delay=0.075
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    tput civis  # hide cursor
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for i in $(seq 0 ${#spinstr}); do
            echo -ne "${YELLOW}${spinstr:i:1}${NC}"
            sleep $delay
            echo -ne "\r"
        done
    done
    tput cnorm  # show cursor
}

# Welcome message with professional title screen
echo -e "${MAGENTA}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║             WELCOME TO THE NOCKAPP INSTALLER             ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║     The installation script designed with precision      ║"
echo "║           and made for a superior experience.            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
sleep 1

# Prompt to begin
echo -e "${CYAN}Press [ENTER] to begin the elegant installation...${NC}"
read

# Step 1: Check if Cargo is installed
echo -e "${YELLOW}Checking for Cargo...${NC}"
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Cargo not found! Installing Rust and Cargo...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &> /dev/null &
    spinner
    source "$HOME/.cargo/env"
else
    echo -e "${GREEN}Cargo is already installed.${NC}"
fi
sleep 1

# Step 2: Install system dependencies
echo -e "${YELLOW}Installing system dependencies...${NC}"
sudo apt-get update -qq &
spinner
sudo apt-get install -y clang llvm &> /dev/null &
spinner
echo -e "${GREEN}Dependencies installed successfully!${NC}"
sleep 1

# Step 3: Set LIBCLANG_PATH for environment setup
echo -e "${YELLOW}Configuring environment variables...${NC}"
export LIBCLANG_PATH=/usr/lib/llvm-10/lib
export CC=clang
sleep 1

# Step 4: Check if the nockapp directory exists, and remove it if necessary
if [ -d "nockapp" ]; then
    echo -e "${YELLOW}The 'nockapp' directory already exists. Removing it...${NC}"
    rm -rf nockapp
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}'nockapp' directory removed successfully.${NC}"
    else
        echo -e "${RED}Error removing 'nockapp' directory. Please check your permissions.${NC}"
        exit 1
    fi
fi

# Step 5: Clone the GitHub repository
echo -e "${YELLOW}Cloning the NockApp repository...${NC}"
git clone --depth=1 https://github.com/zorp-corp/nockapp.git &> /dev/null &
spinner
cd nockapp

# Enhanced Search for Cargo.toml
CARGO_FILE=$(find . -name Cargo.toml | head -n 1)

# If Cargo.toml is found, navigate to the correct directory
if [ -n "$CARGO_FILE" ]; then
    DIR=$(dirname "$CARGO_FILE")
    echo -e "${GREEN}Found Cargo.toml in: $DIR${NC}"
    cd "$DIR"
else
    echo -e "${RED}Error: Cargo.toml not found. Please check the repository structure.${NC}"
    exit 1
fi

# Step 6: Build the project using Cargo
echo -e "${YELLOW}Building NockApp...${NC}"
cargo build --release &> /dev/null &
spinner
echo -e "${GREEN}NockApp built successfully!${NC}"
sleep 1

# Step 7: Run the choo binary explicitly
echo -e "${YELLOW}Executing your custom Hoon program (choo binary)...${NC}"
cargo run --release --bin choo &
spinner
echo -e "${GREEN}Program executed successfully!${NC}"
sleep 1

# Final thank you message with style
echo -e "${MAGENTA}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        THANK YOU FOR INSTALLING AND RUNNING NOCKAPP!     ║"
echo "║  This process was brought to you with unmatched quality. ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║    Feel free to explore, contribute, and grow with us!   ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Optional terminal bell sound to indicate completion
echo -en "\007"
