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
    echo -e "${ORANGE}🚀 Creating Cargo.toml file...${NC}"
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
    echo -e "${PINK}✔️  Cargo.toml created with default settings.${NC}"
}

# Check if the necessary directories and files exist, and create them if not
check_and_create_project_structure() {
    if [ ! -d "src/bin" ]; then
        echo -e "${ORANGE}⚠️  src/bin directory missing, creating it...${NC}"
        mkdir -p src/bin
    fi

    # Create a basic choo.rs file if it doesn't exist
    if [ ! -f "src/bin/choo.rs" ]; then
        echo -e "${ORANGE}⚠️  src/bin/choo.rs missing, creating a minimal file...${NC}"
        cat <<EOL > src/bin/choo.rs
fn main() {
    println!("Running the NockApp Choo binary...");
}
EOL
        echo -e "${PINK}✔️  Created src/bin/choo.rs.${NC}"
    fi

    # Create a basic http_app.rs file if it doesn't exist
    if [ ! -f "src/bin/http_app.rs" ]; then
        echo -e "${ORANGE}⚠️  src/bin/http_app.rs missing, creating a minimal file...${NC}"
        cat <<EOL > src/bin/http_app.rs
fn main() {
    println!("Running the NockApp HTTP App binary...");
}
EOL
        echo -e "${PINK}✔️  Created src/bin/http_app.rs.${NC}"
    fi
}

# Welcome message
echo -e "${PINK}${BOLD}🚀 WELCOME TO THE NOCKAPP INSTALLER 🚀${NC}"
sleep 1

# Check if Cargo is installed
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

# Check if Cargo.toml exists and create it if missing or empty
if [ ! -f "Cargo.toml" ] || [ ! -s "Cargo.toml" ]; then
    echo -e "${RED}⚠️  Cargo.toml is missing or empty! Rebuilding it...${NC}"
    create_cargo_toml
else
    echo -e "${PINK}✔️  Cargo.toml is already configured.${NC}"
fi

# Check and create project structure if missing
check_and_create_project_structure

# Build the project
echo -e "${ORANGE}🔨 Building NockApp...${NC}"
cargo build --release --verbose
if [ $? -ne 0 ]; then
    echo -e "${RED}⚠️  Build failed! Deleting the directory and rebuilding...${NC}"
    cd ..
    rm -rf nockapp
    exec "$0"  # Restart the script
    exit 1
fi

# Check if the binaries are available
echo -e "${ORANGE}🚀 Detecting the correct binary to run...${NC}"
if [ -d "choo" ]; then
    echo -e "${PINK}✔️  'choo' directory found. Running kernel program...${NC}"
    cd choo
    cargo run --release hoon/lib/kernel.hoon
elif [ -f "./target/release/http-app" ]; then
    echo -e "${PINK}✔️  'http-app' binary found. Running it now...${NC}"
    ./target/release/http-app
else
    echo -e "${RED}⚠️  Neither 'choo' directory nor 'http-app' binary found. Checking possible errors...${NC}"
    ls ./target/release
    exit 1
fi

# Final thank you message
echo -e "${PINK}${BOLD}🎉 THANK YOU FOR INSTALLING AND RUNNING NOCKAPP! 🎉${NC}"

# Optional terminal bell sound to indicate completion 🎯
echo -en "\007"
