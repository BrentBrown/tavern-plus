#!/bin/bash

# Tavern.Plus GitHub Project Issue Creator (Enhanced)
# Supports: title as CLI arg, clipboard body, color output, help text

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
  echo -e "${CYAN}Usage:${RESET} addtask \"<title>\" [--from-clipboard]"
  echo -e "${CYAN}Example:${RESET} addtask \"frontend: install TailwindCSS\""
  echo -e "         addtask \"contract: deploy Gold\" --from-clipboard"
  exit 0
fi

# Validate title
TITLE="$1"
if [ -z "$TITLE" ]; then
  echo -e "${RED}❌ You must provide an issue title.${RESET}"
  echo "Try: addtask \"Your title here\""
  exit 1
fi

# Fetch or enter body
if [ "$2" == "--from-clipboard" ]; then
  echo -e "${YELLOW}📄 Using issue body from clipboard...${RESET}"
  BODY=$(pbpaste)
else
  echo -e "${CYAN}📄 Enter Issue Body. Type EOF on a new line when finished:${RESET}"
  BODY=""
  while IFS= read -r LINE; do
    [[ "$LINE" == "EOF" ]] && break
    BODY+="$LINE"$'\n'
  done
fi

if [[ -z "$BODY" ]]; then
  echo -e "${YELLOW}⚠️  No body entered. Proceeding with empty body.${RESET}"
fi

# Create the issue
echo -e "${CYAN}📤 Creating issue: ${RESET}$TITLE"
ISSUE_URL=$(gh issue create \
  --repo "$REPO" \
  --title "$TITLE" \
  --body "$BODY")

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
echo -e "${YELLOW}👉 Reminder: manually move it to the correct column.${RESET}"
