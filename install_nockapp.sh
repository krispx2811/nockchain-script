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

# Create Cargo.toml if it's missing or empty
create_cargo_toml() {
    cat <<EOL > Cargo.toml
[package]
name = "nockapp"
version = "0.1.0"
edition = "2021"

[dependencies]
crown = "0.1.0"
sword = "0.1.0"

[[bin]]
name = "choo"
path = "src/bin/choo.rs"

[[bin]]
name = "http-app"
path = "src/bin/http_app.rs"
EOL
}

# Check and create project structure if missing
check_and_create_project_structure() {
    if [ ! -d "src/bin" ]; then
        mkdir -p src/bin
    fi

    if [ ! -f "src/bin/choo.rs" ]; then
        cat <<EOL > src/bin/choo.rs
fn main() {
    println!("Running the NockApp Choo binary...");
}
EOL
    fi

    if [ ! -f "src/bin/http_app.rs" ]; then
        cat <<EOL > src/bin/http_app.rs
fn main() {
    println!("Running the NockApp HTTP App binary...");
}
EOL
    fi
}

# Welcome message
echo -e "${PINK}${BOLD}🚀 WELCOME TO THE NOCKAPP INSTALLER 🚀${NC}"

# Check if Cargo is installed
echo -e "${ORANGE}🚀 Checking for Cargo...${NC}"
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}⚠️  Cargo not found! Installing Rust and Cargo...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &> /dev/null &
    spinner
    source "$HOME/.cargo/env"
else
    echo -e "${PINK}✔️  Cargo is already installed.${NC}"
fi

# Remove old directory if exists
if [ -d "nockapp" ]; then
    rm -rf nockapp
fi

# Clone the GitHub repository
echo -e "${ORANGE}🌐 Cloning the NockApp repository...${NC}"
git clone --depth=1 https://github.com/zorp-corp/nockapp.git &> /dev/null &
spinner

cd nockapp

# Create Cargo.toml if it's missing or empty
if [ ! -f "Cargo.toml" ] || [ ! -s "Cargo.toml" ]; then
    create_cargo_toml
fi

# Check and create project structure if missing
check_and_create_project_structure

# Build the project
echo -e "${ORANGE}🔨 Building NockApp...${NC}"
cargo build --release &> /dev/null &
spinner

if [ $? -ne 0 ]; then
    echo -e "${RED}⚠️  Build failed! Rebuilding...${NC}"
    rm -rf nockapp
    exec "$0"  # Restart the script
    exit 1
fi

# Check if the binaries are available
echo -e "${ORANGE}🚀 Running the NockApp binary...${NC}"
if [ -d "choo" ]; then
    cd choo
    cargo run --release hoon/lib/kernel.hoon &> /dev/null &
    spinner
elif [ -f "./target/release/http-app" ]; then
    ./target/release/http-app &> /dev/null &
    spinner
else
    echo -e "${RED}⚠️  Neither 'choo' directory nor 'http-app' binary found.${NC}"
    exit 1
fi

# Final thank you message
echo -e "${PINK}${BOLD}🎉 THANK YOU FOR INSTALLING AND RUNNING NOCKAPP! 🎉${NC}"
echo -en "\007"
