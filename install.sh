#!/bin/bash

echo "Welcome to Awesome Vim .... Checking for base requirements"

# Function to check for GCC or Clang compiler
check_compiler() {
    if command -v gcc &> /dev/null; then
        echo "GCC is installed."
        gcc --version
    elif command -v clang &> /dev/null; then
        echo "Clang is installed."
        clang --version
    else
        echo "No C compiler found. Please install GCC or Clang."
        exit 1
    fi
}

# OS detect and check for compiler
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux"
    check_compiler

elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    # On macOS, we can check if Xcode Command Line Tools are installed
    if ! xcode-select --print-path &> /dev/null; then
        echo "Xcode Command Line Tools are not installed. Installing now..."
        xcode-select --install
    else
        check_compiler
    fi

elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "Detected Windows (Cygwin/MSYS/WSL)"
    check_compiler

else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Check if .config directory exists
CONFIG_DIR="$HOME/.config"
NVIM_DIR="$CONFIG_DIR/nvim"

if [[ -d "$CONFIG_DIR" ]]; then
    echo ".config directory exists."
    
    # Check if nvim directory exists inside .config
    if [[ -d "$NVIM_DIR" ]]; then
        echo "nvim directory already exists in .config."
        
        # Ask user if they want to delete nvim and install Awesome Vim
        read -p "Do you want to delete the existing nvim configuration and install Awesome Vim? (y/n): " yn
        case $yn in
            [Yy]* ) 
                echo "Deleting existing nvim configuration..."
                rm -rf "$NVIM_DIR" || { echo "Failed to delete nvim directory"; exit 1; }
                ;;
            [Nn]* ) 
                echo "Aborting installation."
                exit 0
                ;;
            * ) 
                echo "Please answer yes or no."
                exit 1
                ;;
        esac
    fi

else
    echo ".config directory does not exist."
    
    # Ask user if they want to create the .config directory
    read -p "Do you want to create the .config directory? (y/n): " yn
    case $yn in
        [Yy]* )
            mkdir -p "$CONFIG_DIR" || { echo "Failed to create .config directory"; exit 1; }
            echo ".config directory created."
            ;;
        [Nn]* )
            echo "Aborting installation."
            exit 0
            ;;
        * )
            echo "Please answer yes or no."
            exit 1
            ;;
    esac
fi

# Clone Awesome Vim configuration into .config/nvim
echo "Cloning Awesome Vim..."
git clone https://github.com/PythonHacker24/awesomevim.git "$NVIM_DIR" || { echo "Failed to clone Awesome Vim repository"; exit 1; }

# Source packer.lua and run PackerSync
echo "Running PackerSync..."
nvim -c 'luafile ~/.config/nvim/custom/packer.lua' -c 'PackerSync'
echo "Plugins installed successfully!"

# Configuring AwesomeVim
echo "Configuring AwesomeVim..."


# Update init.lua to use Awesome theme
echo 'require("startup").setup({theme = "awesome"})' >> "$HOME/.config/nvim/init.lua"

# Open Neovim to complete the setup
echo "Opening Neovim..."

# Source and destination file paths
SOURCE_FILE="$NVIM_DIR/custom/awesome.lua"
DEST_FILE="lua/startup/themes/awesome.lua"

# Function to copy the file
copy_file() {
    local dest_dir=$1
    mkdir -p "$dest_dir" || { echo "Failed to create destination directory"; exit 1; }
    cp "$SOURCE_FILE" "$dest_dir/$DEST_FILE" || { echo "Failed to copy file"; exit 1; }
}

# Detect the OS and determine destination path for copying files
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux detected
    echo "Detected Linux"
    dest_dir="$HOME/.local/share/nvim/site/pack/packer/start/startup.nvim"
    copy_file "$dest_dir"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS detected
    echo "Detected macOS"
    dest_dir="$HOME/.local/share/nvim/site/pack/packer/start/startup.nvim"
    copy_file "$dest_dir"

elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows detected (Cygwin/MSYS/WSL)
    echo "Detected Windows"
    dest_dir="/mnt/c/Users/$(whoami)/AppData/Local/nvim/site/pack/packer/start/startup.nvim"
    copy_file "$dest_dir"

else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

nvim
