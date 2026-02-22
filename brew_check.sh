#!/bin/bash

echo "Scanning /Applications for Homebrew candidates..."
echo "-------------------------------------------------------"

# 1. Gather candidates
app_names=()
app_tokens=()
INSTALLED_CASKS=$(brew list --cask -1 2>/dev/null)

while read -r app_path; do
    app_name=$(basename "$app_path" .app)
    token=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[()//]//g')

    # Skip if already in Homebrew
    if echo "$INSTALLED_CASKS" | grep -q "^$token$"; then
        continue
    fi

    # Check if Cask exists
    if brew info --cask "$token" &>/dev/null; then
        app_names+=("$app_name")
        app_tokens+=("$token")
    fi
done < <(find /Applications -maxdepth 1 -name "*.app")

# 2. Check if we found anything
if [ ${#app_names[@]} -eq 0 ]; then
    echo "No new candidates found. Everything looks good!"
    exit 0
fi

# 3. Display Menu
echo "The following apps can be converted to Homebrew:"
for i in "${!app_names[@]}"; do
    printf "%2d) %-25s (%s)\n" "$((i+1))" "${app_names[$i]}" "${app_tokens[$i]}"
done

echo "-------------------------------------------------------"
echo "Enter the numbers to convert (e.g., '1 3 5')."
echo "Leave blank and press ENTER to convert ALL."
read -p "Selection: " input

# 4. Process Selection
to_install=()
if [ -z "$input" ]; then
    to_install=("${app_tokens[@]}")
else
    for num in $input; do
        index=$((num-1))
        if [[ $index -ge 0 && $index -lt ${#app_tokens[@]} ]]; then
            to_install+=("${app_tokens[$index]}")
        fi
    done
fi

# 5. Execution
if [ ${#to_install[@]} -gt 0 ]; then
    echo "Starting conversion for: ${to_install[*]}"
    for token in "${to_install[@]}"; do
        echo "--> Installing $token..."
        brew install --cask --force "$token"
    done
    
    # Update Brewfile
    echo "Updating ~/.Brewfile..."
    brew bundle dump --file="$HOME/.Brewfile" --force 2>/dev/null
    echo "Done!"
else
    echo "No valid selections made. Exiting."
fi
