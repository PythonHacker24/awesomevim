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

UNDO_DIR="$HOME/.undodir"

# Check if the directory exists
if [[ -d "$UNDO_DIR" ]]; then
    echo "$UNDO_DIR already exists."
else
    echo "$UNDO_DIR does not exist. Creating it now..."
    mkdir -p "$UNDO_DIR" || { echo "Failed to create $UNDO_DIR"; exit 1; }
    echo "$UNDO_DIR created successfully."
fi


echo "Ready to proceed with Awesome Vim installation!"

# Clone Awesome Vim configuration into .config/nvim
echo "Cloning Awesome Vim..."
git clone https://github.com/PythonHacker24/awesomevim.git "$NVIM_DIR" || { echo "Failed to clone Awesome Vim repository"; exit 1; }

# Source packer.lua and run PackerSync
echo "Running PackerSync..."
nvim -c 'luafile ~/.config/nvim/custom/packer.lua' -c 'PackerSync' -c 'autocmd User PackerComplete quitall'
echo "Plugins installed successfully!"

echo "Awesome Vim installed successfully. Fire it up with command: nvim"
