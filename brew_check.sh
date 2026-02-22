#!/bin/bash

echo "Starting Homebrew Conversion Tool..."
echo "-------------------------------------------------------"

# 1. Update Homebrew (Optional, can be slow so feel free to comment out)
# brew update

# 2. Get currently managed casks
INSTALLED_CASKS=$(brew list --cask -1 2>/dev/null)

# 3. Find and Convert
# Using < <(find...) prevents the stdin conflict
while read -r app_path; do
    app_name=$(basename "$app_path" .app)
    
    # Token conversion
    token=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[()//]//g')

    # Skip if already managed by brew
    if echo "$INSTALLED_CASKS" | grep -q "^$token$"; then
        continue
    fi

    # Check if a Cask exists
    if brew info --cask "$token" &>/dev/null; then
        # IMPORTANT: < /dev/tty forces the script to wait for YOUR keyboard input
        echo -n "Found Match: $app_name ($token). Convert? (y/N): "
        read -r response < /dev/tty
        
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "--> Installing $token via Homebrew..."
            brew install --cask --force "$token"
            
            if [ $? -eq 0 ]; then
                echo "--> SUCCESS: $app_name is now managed by Brew."
                # Update Brewfile if you want it tracked
                brew bundle dump --file="$HOME/.Brewfile" --force 2>/dev/null
            else
                echo "--> ERROR: Failed to install $token."
            fi
            echo "-------------------------------------------------------"
        fi
    fi
done < <(find /Applications -maxdepth 1 -name "*.app")

echo "Conversion process complete."
