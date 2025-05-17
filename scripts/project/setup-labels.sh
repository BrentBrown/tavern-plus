#!/bin/bash
# Script to configure GitHub issue labels with consistent color mapping
# Usage: ./scripts/project/setup-labels.sh

set -e

REPO="BrentBrown/tavern-plus"

# Using parallel arrays instead of associative arrays for bash 3.2 compatibility
LABEL_NAMES=(
  "backend"
  "infra"
  "tooling"
  "smart-contracts"
  "tests"
  "setup"
  "mvp"
  "reputation"
  "identity"
  "sessions"
  "bug"
  "docs"
  "enhancement"
  "wontfix"
)

LABEL_COLORS=(
  "#1f6feb"
  "#388bfd"
  "#96ccff"
  "#0e8a16"
  "#2da44e"
  "#6fdd8b"
  "#ffd33d"
  "#8250df"
  "#a371f7"
  "#cf222e"
  "#d73a49"
  "#6e7781"
  "#a2cbf7"
  "#d4c5f9"
)

echo "🎯 Updating labels in GitHub repo: $REPO"

for i in "${!LABEL_NAMES[@]}"; do
  label="${LABEL_NAMES[$i]}"
  color="${LABEL_COLORS[$i]}"
  if gh label list --repo "$REPO" | grep -q "^$label"; then
    echo "✅ Label '$label' exists. Updating color to $color..."
    gh label edit "$label" --repo "$REPO" --color "${color/#\#}" --description "" >/dev/null
  else
    echo "➕ Label '$label' not found. Creating with color $color..."
    gh label create "$label" --repo "$REPO" --color "${color/#\#}" --description "" >/dev/null
  fi
done

echo "✅ All labels are updated and aligned with the color scheme."