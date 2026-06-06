#!/bin/bash
# setup_terminal.sh - Script to setup terminal font and Starship prompt on macOS

set -euo pipefail

echo "==========================================="
echo "   Terminal & Prompt Setup Script (macOS)  "
echo "==========================================="

# 1. Setup Starship Prompt
echo "Step 1: Setting up Starship prompt..."

if ! command -v starship &> /dev/null; then
    echo "Starship is not installed. Installing Starship..."
    if command -v brew &> /dev/null; then
        echo "Installing via Homebrew..."
        brew install starship
    else
        echo "Homebrew not found. Installing via official curl script..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi
else
    echo "✓ Starship is already installed."
fi

# Create configuration directory
mkdir -p ~/.config

# Write starship.toml configuration
echo "Writing starship.toml config..."
cat << 'EOF' > ~/.config/starship.toml
format = "$directory$git_branch\n$character"

[directory]
truncation_length = 2
truncate_to_repo = true
style = "bold cyan"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
EOF
echo "✓ ~/.config/starship.toml created."

# Add to ~/.zshrc if not already there
ZSHRC="$HOME/.zshrc"
INIT_LINE='eval "$(starship init zsh)"'
if [ -f "$ZSHRC" ]; then
    if grep -Fq "$INIT_LINE" "$ZSHRC"; then
        echo "✓ Starship init already configured in ~/.zshrc."
    else
        echo "Configuring Starship init in ~/.zshrc..."
        echo -e "\n# Starship Prompt\n$INIT_LINE" >> "$ZSHRC"
        echo "✓ Added to ~/.zshrc."
    fi
else
    echo "Creating ~/.zshrc and adding Starship init..."
    echo -e "# Starship Prompt\n$INIT_LINE" > "$ZSHRC"
    echo "✓ ~/.zshrc created."
fi

# 2. Setup VS Code Terminal font settings
echo -e "\nStep 2: Setting up VS Code terminal settings..."
SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    echo "Updating VS Code settings.json..."
    python3 -c "
import json
import os

path = os.path.expanduser('~/Library/Application Support/Code/User/settings.json')
try:
    with open(path, 'r', encoding='utf-8') as f:
        # Strip simple comments or try parsing directly
        data = json.load(f)
except Exception as e:
    print(f'Error reading settings.json: {e}')
    data = {}

# Update terminal settings to Menlo 12px
data['terminal.integrated.fontFamily'] = 'Menlo, Monaco, \"Courier New\", monospace'
data['terminal.integrated.fontSize'] = 12
data['terminal.integrated.lineHeight'] = 1.2

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
print('✓ VS Code terminal font settings updated successfully.')
"
else
    echo "VS Code settings.json not found at expected path. Skipping VS Code config."
fi

echo -e "\n==========================================="
echo "✓ Setup complete! Please restart your terminal."
echo "==========================================="
