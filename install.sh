#!/bin/bash

# OP Mode Installer for Unix/macOS

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  OP Mode - Orchestration Protocol Installer                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set target directory
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
TARGET_DIR="$COMMANDS_DIR/op-mode"

# Create directories if they don't exist
echo "[1/3] Creating directories..."
mkdir -p "$COMMANDS_DIR"

# Check if op-mode already exists
if [ -d "$TARGET_DIR" ]; then
    echo "  ⚠️  Existing op-mode installation found."
    read -p "  Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "  Installation cancelled."
        exit 0
    fi
    rm -rf "$TARGET_DIR"
fi

# Copy files
echo "[2/3] Installing OP Mode skill..."
cp -r "$SCRIPT_DIR/commands/op-mode" "$TARGET_DIR"

# Verify installation
echo "[3/3] Verifying installation..."
if [ -f "$TARGET_DIR/SKILL.md" ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  ✓ OP Mode installed successfully!                           ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  Location: ~/.claude/commands/op-mode/                       ║"
    echo "║                                                              ║"
    echo "║  Usage:                                                      ║"
    echo "║    /op-mode <task description>                               ║"
    echo "║                                                              ║"
    echo "║  Example:                                                    ║"
    echo "║    /op-mode Add user authentication with OAuth               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
else
    echo "  ❌ Installation failed. SKILL.md not found."
    exit 1
fi

# Optional: Create .uop directory for memory
echo ""
read -p "Create .uop/ memory directory in current project? (y/N): " create_uop
if [ "$create_uop" = "y" ] || [ "$create_uop" = "Y" ]; then
    mkdir -p ".uop/sessions" ".uop/history/decisions" ".uop/history/issues" ".uop/history/patterns" ".uop/summaries"
    echo "# OP Mode Index" > ".uop/INDEX.md"
    echo "  ✓ Created .uop/ directory structure"
fi

echo ""
echo "Done! Start using OP Mode with: /op-mode <your task>"
