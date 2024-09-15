# Paths to .config and nvim directories
CONFIG_DIR="$HOME/.config"
NVIM_DIR="$CONFIG_DIR/nvim"

# Check if the .config directory exists
if [[ -d "$CONFIG_DIR" ]]; then
    echo ".config directory exists."

    # Check if the nvim directory exists inside .config
    if [[ -d "$NVIM_DIR" ]]; then
        echo "nvim directory already exists in .config."
        
        # Ask the user if they want to delete the existing nvim directory and install Awesome Vim
        while true; do
            echo "Do you want to delete the existing nvim configuration and install Awesome Vim? (y/n)"
            read yn
            case $yn in
                [Yy]* ) 
                    echo "Deleting existing nvim configuration..."
                    rm -rf "$NVIM_DIR" || { echo "Failed to delete nvim directory"; exit 1; }
                    echo "nvim directory deleted."
                    break
                    ;;
                [Nn]* ) 
                    echo "Aborting installation."
                    exit 0
                    ;;
                * ) 
                    echo "Please answer with 'y' for yes or 'n' for no."
                    ;;
            esac
        done
    fi

else
    echo ".config directory does not exist."

    # Ask the user if they want to create the .config directory
    while true; do
        echo "Do you want to create the .config directory? (y/n)"
        read yn
        case $yn in
            [Yy]* ) 
                mkdir -p "$CONFIG_DIR" || { echo "Failed to create .config directory"; exit 1; }
                echo ".config directory created."
                break
                ;;
            [Nn]* ) 
                echo "Aborting installation."
                exit 0
                ;;
            * ) 
                echo "Please answer with 'y' for yes or 'n' for no."
                ;;
        esac
    done
fi
