#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root: MAKE resolves every path from the current directory.
cd "$(dirname "$0")"
MAKEFILE="${MAKEFILE:-MAKE}"
export PATH="${HOME}/.elan/bin:${PATH}"

echo "========================================"
echo "Start setting up project: Lean Research Project"
echo "========================================"

# ----------------------------
# Step 1: sanity checks
# ----------------------------
if ! command -v git >/dev/null 2>&1; then
  echo "git is not installed or not in PATH"
  echo "  macOS: xcode-select --install   Linux: sudo apt install git"
  exit 1
fi

if ! command -v rclone >/dev/null 2>&1; then
  echo "rclone is not installed or not in PATH"
  echo
  echo "Install options:"
  echo "  macOS (Homebrew): brew install rclone"
  echo "  Linux:            sudo apt install rclone"
  echo "  Manual:           https://rclone.org/install/"
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is not installed or not in PATH"
  echo
  echo "Install options:"
  echo "  macOS (Homebrew): brew install uv"
  echo "  Linux:            curl -LsSf https://astral.sh/uv/install.sh | sh"
  echo "  Manual:           https://docs.astral.sh/uv/"
  exit 1
fi

if ! command -v elan >/dev/null 2>&1; then
  echo "elan (the Lean version manager) is not installed or not in PATH"
  echo
  echo "Install options:"
  echo "  macOS/Linux: curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- -y --default-toolchain none"
  echo "  Manual:      https://lean-lang.org/install/"
  exit 1
fi

echo "elan found: $(elan --version)"

if ! command -v xelatex >/dev/null 2>&1 && ! command -v pdflatex >/dev/null 2>&1; then
  echo "WARNING: LaTeX is not installed (xelatex or pdflatex not found)."
  echo "         Only PDF exports of the book need it (macOS: https://tug.org/mactex/, Linux: sudo apt install texlive-full)."
fi

if ! command -v make >/dev/null 2>&1; then
  echo "make is not installed or not in PATH"
  echo
  echo "Install options:"
  echo "  macOS:         xcode-select --install"
  echo "  Ubuntu/Debian: sudo apt install build-essential"
  exit 1
fi

if [ ! -f "${MAKEFILE}" ]; then
  echo "Makefile '${MAKEFILE}' not found"
  exit 1
fi

# ----------------------------
# Step 2: pull assets and data
# ----------------------------
if rclone listremotes | grep -q '^gdriveuofa:$'; then
  echo "Pulling assets and data from Google Drive..."
  make -f "${MAKEFILE}" pull_drive DRYRUN=""
  echo "Pull completed successfully"
else
  echo "WARNING: rclone remote 'gdriveuofa' not found; skipping Google Drive pull (see README, step 3)."
fi

# ----------------------------
# Step 3: create environments
# ----------------------------
echo "Creating Python environment with uv and downloading Mathlib (this takes a few minutes)..."
make -f "${MAKEFILE}" setup
echo "Initializing environment completed successfully"
