#!/bin/bash

echo "Welcome to Awesome Vim .... Setting up Plugins"

git clone https://github.com/PythonHacker24/awesomevim.git "$HOME/.config/nvim"

# Path to your Neovim configuration directory
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Source packer.lua and run PackerSync
nvim -c 'luafile ~/.config/nvim/custom/packer.lua' -c 'PackerSync'
echo "Plugins installed successfully!"

echo "Configuring AwesomeVim"

# Source and file path
SOURCE_FILE="$HOME/.config/nvim/custom/awesome.lua"
DEST_FILE="lua/startup/themes/awesome.lua"

# Function to copy the file
copy_file() {
    local dest_dir=$1
    mkdir -p "$dest_dir" || { echo "Failed to create destination directory"; exit 1; }
    cp "$SOURCE_FILE" "$dest_dir/$DEST_FILE" || { echo "Failed to copy file"; exit 1; }
}

# Detect the OS
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

echo 'require("startup").setup({theme = "awesome"})' >> "$HOME/.config/nvim/init.lua"

nvim
