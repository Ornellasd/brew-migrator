#!/bin/bash

echo "🍺 Brew-Migrator: Homebrew Conversion Tool"
echo "-------------------------------------------------------"

# 1. Ask for Mode
echo "Select mode:"
echo "1) Live Conversion (Actually install/overwrite apps)"
echo "2) Dry Run (Just show what would happen)"
read -p "Selection [1/2]: " mode_choice

DRY_RUN=true
if [[ "$mode_choice" == "1" ]]; then
    DRY_RUN=false
    echo "🚀 LIVE MODE ACTIVE"
else
    echo "🛡️ DRY RUN MODE ACTIVE (No changes will be made)"
fi
echo "-------------------------------------------------------"

# 2. Gather candidates
app_names=()
app_tokens=()
INSTALLED_CASKS=$(brew list --cask -1 2>/dev/null)

while read -r app_path; do
    app_name=$(basename "$app_path" .app)
    token=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[()//]//g')

    if echo "$INSTALLED_CASKS" | grep -q "^$token$"; then
        continue
    fi

    if brew info --cask "$token" &>/dev/null; then
        app_names+=("$app_name")
        app_tokens+=("$token")
    fi
done < <(find /Applications -maxdepth 1 -name "*.app")

if [ ${#app_names[@]} -eq 0 ]; then
    echo "No new candidates found. Everything looks good!"
    exit 0
fi

# 3. Display Menu
echo "Candidates found:"
for i in "${!app_names[@]}"; do
    printf "%2d) %-25s (%s)\n" "$((i+1))" "${app_names[$i]}" "${app_tokens[$i]}"
done

echo "-------------------------------------------------------"
echo "Enter numbers to convert (e.g., '1 3 5') or ENTER for ALL."
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
    for token in "${to_install[@]}"; do
        
        # Check if app is running (Live Mode only)
        if [ "$DRY_RUN" = false ]; then
            if pgrep -f "$token" > /dev/null; then
                echo "⚠️  WARNING: $token appears to be running. Please close it before converting."
                continue
            fi
            
            echo "--> Installing $token..."
            brew install --cask --force "$token"
        else
            echo "[DRY RUN] Would run: brew install --cask --force $token"
        fi
    done
    
    if [ "$DRY_RUN" = false ]; then
        echo "Updating ~/.Brewfile..."
        brew bundle dump --file="$HOME/.Brewfile" --force 2>/dev/null
        echo "Done!"
    fi
else
    echo "No valid selections made."
fi
