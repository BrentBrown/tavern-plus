#!/bin/bash

# Tavern.Plus GitHub Project Issue Creator (Enhanced)
# Supports: --title, --body, --labels, --sort, color output, help text

REPO="BrentBrown/tavern-plus"
PROJECT_ID="PVT_kwHOAATKCc4A5MuQ"

# ANSI color codes
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Show help if needed
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo -e "${CYAN}Usage:${RESET} addtask --title \"<title>\" [--body \"<body>\"] [--labels \"label1,label2\"] [--sort <number>]"
  echo -e "${CYAN}Example:${RESET} addtask --title \"frontend: install TailwindCSS\" --body \"Install via npm and configure.\" --labels \"frontend,priority-high\" --sort 2"
  exit 0
fi

# Initialize variables
TITLE=""
BODY=""
LABELS=""
SORT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      shift
      TITLE="$1"
      ;;
    --body)
      shift
      BODY="$1"
      ;;
    --labels)
      shift
      LABELS="$1"
      ;;
    --sort)
      shift
      SORT="$1"
      ;;
    *)
      echo -e "${RED}❌ Unknown argument: $1${RESET}"
      exit 1
      ;;
  esac
  shift
done

# Validate title
if [ -z "$TITLE" ]; then
  echo -e "${RED}❌ You must provide an issue title with --title.${RESET}"
  echo "Try: addtask --title \"Your title here\""
  exit 1
fi

if [[ -z "$BODY" ]]; then
  echo -e "${YELLOW}⚠️  No body provided. Proceeding with empty body.${RESET}"
fi

# Prepare labels argument
LABEL_ARG=()
if [[ -n "$LABELS" ]]; then
  IFS=',' read -ra LABEL_ARRAY <<< "$LABELS"
  for label in "${LABEL_ARRAY[@]}"; do
    # Check if label exists
    if ! gh label list --repo "$REPO" | grep -Fxq "$label"; then
      echo -e "${YELLOW}⚠️  Label '$label' does not exist. Creating it...${RESET}"
      gh label create "$label" --repo "$REPO" --color "ededed" --description ""
    fi
    LABEL_ARG+=(--label "$label")
  done
fi

# Create the issue
echo -e "${CYAN}📤 Creating issue: ${RESET}$TITLE"
ISSUE_URL=$(gh issue create \
  --repo "$REPO" \
  --title "$TITLE" \
  --body "$BODY" \
  "${LABEL_ARG[@]}")

if [[ -z "$ISSUE_URL" ]]; then
  echo -e "${RED}❌ Issue creation failed.${RESET}"
  exit 1
fi

ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
ISSUE_ID=$(gh issue view "$ISSUE_NUMBER" --repo "$REPO" --json id | jq -r '.id')

if [[ -z "$ISSUE_ID" ]]; then
  echo -e "${RED}❌ Could not retrieve issue ID.${RESET}"
  exit 1
fi

echo -e "${GREEN}✅ Issue #$ISSUE_NUMBER created: $ISSUE_URL${RESET}"

# Add to project board
echo -e "${CYAN}📋 Adding to project board...${RESET}"
gh api graphql -f query='
mutation($project: ID!, $issue: ID!) {
  addProjectV2ItemById(input: {
    projectId: $project,
    contentId: $issue
  }) {
    item {
      id
    }
  }
}' -f project="$PROJECT_ID" -f issue="$ISSUE_ID"

echo -e "${GREEN}✅ Issue added to project board (in 'No Status').${RESET}"

if [[ -n "$SORT" ]]; then
  echo -e "${YELLOW}👉 Reminder: GitHub Projects API v2 does not support setting sort order via API.${RESET}"
  echo -e "${YELLOW}👉 Please set the sort order manually for issue #$ISSUE_NUMBER.${RESET}"
fi
