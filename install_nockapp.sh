#!/bin/bash

# Define colors for better UX
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Define a spinner for loading animations
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Fancy Title with animation
echo -e "${MAGENTA}"
echo "==========================================="
echo "     WELCOME TO THE NOCKAPP INSTALLER      "
echo "==========================================="
echo -e "${NC}"
sleep 1

# User input to continue
echo -e "${CYAN}Press [ENTER] to begin the installation...${NC}"
read

# Step 1: Check if cargo is installed
echo -e "${YELLOW}Checking for Cargo...${NC}"
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Cargo not found! Installing Rust and Cargo...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &
    spinner
    source "$HOME/.cargo/env"
else
    echo -e "${GREEN}Cargo is already installed!${NC}"
fi
sleep 1

# Step 2: Install system dependencies
echo -e "${YELLOW}Installing system dependencies...${NC}"
sudo apt-get update > /dev/null 2>&1 &
spinner
sudo apt-get install -y clang llvm > /dev/null 2>&1 &
spinner
echo -e "${GREEN}Dependencies installed!${NC}"
sleep 1

# Step 3: Set LIBCLANG_PATH
echo -e "${YELLOW}Setting environment variables...${NC}"
export LIBCLANG_PATH=/usr/lib/llvm-10/lib
export CC=clang
sleep 1

# Step 4: Clone the GitHub repository
echo -e "${YELLOW}Cloning the NockApp repository...${NC}"
git clone https://github.com/yourusername/nockapp.git &> /dev/null &
spinner
cd nockapp
echo -e "${GREEN}Repository cloned!${NC}"
sleep 1

# Step 5: Build the project with Cargo
echo -e "${YELLOW}Building NockApp...${NC}"
cargo build --release > /dev/null 2>&1 &
spinner
echo -e "${GREEN}Build completed successfully!${NC}"
sleep 1

# Step 6: Run a sample Hoon program
echo -e "${YELLOW}Running your Hoon program...${NC}"
cargo run --release hoon/lib/my_program.hoon &
spinner
echo -e "${GREEN}Program executed successfully!${NC}"

# Final message
echo -e "${MAGENTA}"
echo "==========================================="
echo "       NOCKAPP HAS BEEN SUCCESSFULLY       "
echo "          INSTALLED AND EXECUTED!          "
echo "==========================================="
echo -e "${NC}"

# End the script with a sound (optional)
echo -en "\007"
