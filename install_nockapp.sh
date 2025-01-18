#!/bin/bash

# ============================================================
# NockApp Installer Script
# ============================================================
# This script installs NockApp along with all its dependencies.
# It provides clear progress indicators and robust error handling.
# ============================================================

# ----------------------------
# Define Colors for Output
# ----------------------------
PINK='\033[38;5;205m'
ORANGE='\033[38;5;214m'
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
BLUE='\033[38;5;51m'
BOLD='\033[1m'
NC='\033[0m'  # No Color

# ----------------------------
# Function: Display Messages
# ----------------------------
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${BOLD}${message}${NC}"
}

# ----------------------------
# Function: Display Progress Bar
# ----------------------------
complete_progress() {
    local task="$1"
    local bar_length=50
    local filled_length=$bar_length
    local empty_length=$((bar_length - filled_length))
    local filled_bar=$(printf "%0.s#" $(seq 1 $filled_length))
    local empty_bar=$(printf "%0.s " $(seq 1 $empty_length))
    printf "[%s%s] 100%% %s\n" "$filled_bar" "$empty_bar" "$task"
}

# ----------------------------
# Function: Handle Errors
# ----------------------------
handle_error() {
    local exit_code=$1
    local step="$2"
    if [ $exit_code -ne 0 ]; then
        print_message "$RED" "❌  Error during: $step"
        exit $exit_code
    fi
}

# ----------------------------
# Function: Check and Install Dependencies
# ----------------------------
install_dependencies() {
    local dependencies=("git" "cargo" "curl" "wget" "tput" "build-essential")
    missing_deps=()

    print_message "$ORANGE" "🔍 Checking for required dependencies..."

    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_message "$GREEN" "✔️  All dependencies are already installed."
    else
        print_message "$ORANGE" "⚠️  Missing dependencies detected: ${missing_deps[*]}"
        print_message "$ORANGE" "🔧 Installing missing dependencies..."

        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                git)
                    install_git
                    handle_error $? "Installing Git"
                    complete_progress "Git installed successfully."
                    ;;
                cargo)
                    install_rust
                    handle_error $? "Installing Rust and Cargo"
                    complete_progress "Rust and Cargo installed successfully."
                    ;;
                curl)
                    install_curl
                    handle_error $? "Installing curl"
                    complete_progress "curl installed successfully."
                    ;;
                wget)
                    install_wget
                    handle_error $? "Installing wget"
                    complete_progress "wget installed successfully."
                    ;;
                tput)
                    install_tput
                    handle_error $? "Installing tput"
                    complete_progress "tput installed successfully."
                    ;;
                build-essential)
                    install_build_essential
                    handle_error $? "Installing build-essential"
                    complete_progress "build-essential installed successfully."
                    ;;
                *)
                    print_message "$RED" "❌  Unknown dependency: $dep"
                    ;;
            esac
        done
    fi
}

# ----------------------------
# Function: Install Git
# ----------------------------
install_git() {
    print_message "$BLUE" "🚀 Installing Git..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install git -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git
    else
        print_message "$RED" "❌  Unsupported OS for automatic Git installation."
        exit 1
    fi
}

# ----------------------------
# Function: Install Rust and Cargo
# ----------------------------
install_rust() {
    print_message "$BLUE" "🚀 Installing Rust and Cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    handle_error $? "Downloading Rust installer"
    source "$HOME/.cargo/env"
}

# ----------------------------
# Function: Install Curl
# ----------------------------
install_curl() {
    print_message "$BLUE" "🚀 Installing curl..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install curl -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install curl
    else
        print_message "$RED" "❌  Unsupported OS for automatic curl installation."
        exit 1
    fi
}

# ----------------------------
# Function: Install Wget
# ----------------------------
install_wget() {
    print_message "$BLUE" "🚀 Installing wget..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install wget -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install wget
    else
        print_message "$RED" "❌  Unsupported OS for automatic wget installation."
        exit 1
    fi
}

# ----------------------------
# Function: Install tput
# ----------------------------
install_tput() {
    print_message "$BLUE" "🚀 Installing tput..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install ncurses-bin -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ncurses
    else
        print_message "$RED" "❌  Unsupported OS for automatic tput installation."
        exit 1
    fi
}

# ----------------------------
# Function: Install Build Essentials
# ----------------------------
install_build_essential() {
    print_message "$BLUE" "🚀 Installing build-essential..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install build-essential -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_message "$BLUE" "🚀 Installing Xcode Command Line Tools..."
        xcode-select --install
        handle_error $? "Installing Xcode Command Line Tools"
    else
        print_message "$RED" "❌  Unsupported OS for automatic build-essential installation."
        exit 1
    fi
}

# ----------------------------
# Function: Create Cargo.toml
# ----------------------------
# Removed to prevent overwriting existing workspace manifest
create_cargo_toml() {
    print_message "$ORANGE" "📄 Skipping Cargo.toml creation to preserve existing workspace configuration."
}

# ----------------------------
# Function: Check and Create Project Structure
# ----------------------------
check_and_create_project_structure() {
    print_message "$ORANGE" "🔧 Checking project structure..."

    # Assuming that workspace members have their own directories and Cargo.toml files
    declare -a members=("crown" "apps/choo" "apps/http-app" "apps/test-app")

    for member in "${members[@]}"; do
        if [ ! -d "$member" ]; then
            mkdir -p "$member"
            handle_error $? "Creating directory $member"
            complete_progress "Created directory $member."
        fi

        # Check for Cargo.toml in each member
        if [ ! -f "$member/Cargo.toml" ]; then
            print_message "$ORANGE" "📄 Creating Cargo.toml for $member..."
            cat <<EOL > "$member/Cargo.toml"
[package]
name = "$(basename "$member")"
version = "0.1.0"
edition = "2021"

[dependencies]
# Add dependencies specific to $member here
EOL
            handle_error $? "Creating Cargo.toml for $member"
            complete_progress "Cargo.toml for $member created successfully."
        fi

        # Check for main.rs or lib.rs as per binary type
        # Assuming binaries have main.rs
        if [ ! -f "$member/src/main.rs" ]; then
            mkdir -p "$member/src"
            print_message "$ORANGE" "📄 Creating main.rs for $member..."
            cat <<EOL > "$member/src/main.rs"
fn main() {
    println!("Running the NockApp $(basename "$member") binary...");
}
EOL
            handle_error $? "Creating main.rs for $member"
            complete_progress "main.rs for $member created successfully."
        fi
    done
}

# ----------------------------
# Function: Clone Repository
# ----------------------------
clone_repository() {
    print_message "$ORANGE" "🌐 Cloning the NockApp repository..."
    git clone --depth=1 https://github.com/zorp-corp/nockapp.git &> /dev/null
    handle_error $? "Cloning Repository"
    complete_progress "Repository cloned successfully."
}

# ----------------------------
# Function: Build the Project
# ----------------------------
build_project() {
    print_message "$ORANGE" "🔨 Building NockApp..."
    cargo build --release
    handle_error $? "Building NockApp"

    # Check if build succeeded by verifying the binaries exist
    if [ -f "./target/release/http-app" ] || [ -f "./target/release/choo" ]; then
        complete_progress "NockApp built successfully."
    else
        print_message "$RED" "❌  Build completed but binaries not found."
        exit 1
    fi
}

# ----------------------------
# Function: Run NockApp Binary
# ----------------------------
run_nockapp() {
    print_message "$ORANGE" "🚀 Running the NockApp binary..."

    if [ -f "./target/release/http-app" ]; then
        # Run the binary in the background
        ./target/release/http-app &
        APP_PID=$!
        sleep 2  # Allow some time for the binary to start
        if ps -p $APP_PID > /dev/null; then
            complete_progress "NockApp is now running with PID $APP_PID."
            echo "NockApp is running in the background with PID $APP_PID."
            echo "You can stop it by running: kill $APP_PID"
        else
            print_message "$RED" "❌  Failed to run the HTTP-App binary."
            exit 1
        fi
    elif [ -f "./target/release/choo" ]; then
        # Run the binary in the background
        ./target/release/choo &
        APP_PID=$!
        sleep 2  # Allow some time for the binary to start
        if ps -p $APP_PID > /dev/null; then
            complete_progress "NockApp is now running with PID $APP_PID."
            echo "NockApp is running in the background with PID $APP_PID."
            echo "You can stop it by running: kill $APP_PID"
        else
            print_message "$RED" "❌  Failed to run the Choo binary."
            exit 1
        fi
    else
        print_message "$RED" "⚠️  Neither 'http-app' nor 'choo' binary found."
        exit 1
    fi
}

# ----------------------------
# Function: Exit Script on Error
# ----------------------------
trap 'echo -e "${RED}❌  An unexpected error occurred. Exiting.${NC}"; exit 1' ERR

# ----------------------------
# Main Installation Flow
# ----------------------------

# Welcome Message
print_message "$PINK" "${BOLD}🚀 WELCOME TO THE NOCKAPP INSTALLER 🚀${NC}"

# Install Dependencies
install_dependencies

# Remove old directory if exists
if [ -d "nockapp" ]; then
    print_message "$ORANGE" "🗑️  Removing existing nockapp directory..."
    rm -rf nockapp
    handle_error $? "Removing old nockapp directory"
    complete_progress "Old nockapp directory removed."
fi

# Clone the Repository
clone_repository

# Navigate to Project Directory
cd nockapp || { print_message "$RED" "❌  Failed to navigate to nockapp directory."; exit 1; }

# Create Cargo.toml if Missing or Empty
if [ ! -f "Cargo.toml" ] || [ ! -s "Cargo.toml" ]; then
    create_cargo_toml
    handle_error $? "Creating Cargo.toml"
    complete_progress "Cargo.toml created successfully."
fi

# Check and Create Project Structure
check_and_create_project_structure

# Install Project Dependencies
print_message "$ORANGE" "📦 Installing project dependencies..."
# Assuming dependencies are managed via Cargo.toml, no additional commands needed here.

# Build the Project
build_project

# Run the NockApp Binary
run_nockapp

# Final Thank You Message
print_message "$PINK" "${BOLD}🎉 THANK YOU FOR INSTALLING AND RUNNING NOCKAPP! 🎉${NC}"
echo -en "\007"  # Beep sound

# Exit Successfully
exit 0
