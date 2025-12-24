#!/bin/bash

###############################################################################
# VALGUARD - GitHub Push Script
# Automates pushing to GitHub
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
cat << "BANNER"

    ╔═══════════════════════════════════════════════════════════╗
    ║     VALGUARD v4.0 - GitHub Push Script                   ║
    ║     Push your security scanner to GitHub                 ║
    ╚═══════════════════════════════════════════════════════════╝

BANNER
echo -e "${NC}"

# Check if git is initialized
if [ ! -d .git ]; then
    echo -e "${RED}[✗]${NC} Git repository not initialized!"
    echo -e "${YELLOW}[!]${NC} Run: git init"
    exit 1
fi

# Get GitHub username
echo -e "${BLUE}[•]${NC} Enter your GitHub username:"
read -p "GitHub username: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}[✗]${NC} Username cannot be empty!"
    exit 1
fi

REPO_URL="https://github.com/${GITHUB_USER}/valguard.git"

echo -e "${GREEN}[✓]${NC} Repository URL: ${REPO_URL}"
echo ""

# Configure git if needed
echo -e "${BLUE}[•]${NC} Configuring Git..."
git config --global user.name "${GITHUB_USER}" 2>/dev/null || true
git config --global user.email "${GITHUB_USER}@users.noreply.github.com" 2>/dev/null || true
echo -e "${GREEN}[✓]${NC} Git configured"
echo ""

# Check for existing remote
if git remote | grep -q origin; then
    echo -e "${YELLOW}[!]${NC} Remote 'origin' already exists"
    read -p "Remove and reconfigure? (y/n): " RECONFIGURE
    if [ "$RECONFIGURE" = "y" ]; then
        git remote remove origin
        echo -e "${GREEN}[✓]${NC} Remote removed"
    fi
else
    # Add remote
    echo -e "${BLUE}[•]${NC} Adding GitHub remote..."
    git remote add origin "$REPO_URL"
    echo -e "${GREEN}[✓]${NC} Remote added"
fi

# Rename branch to main
echo -e "${BLUE}[•]${NC} Configuring main branch..."
git branch -M main 2>/dev/null || true
echo -e "${GREEN}[✓]${NC} Branch set to main"
echo ""

# Show status
echo -e "${CYAN}${BOLD}Current Status:${NC}"
echo -e "  Repository: ${REPO_URL}"
echo -e "  Branch: $(git rev-parse --abbrev-ref HEAD)"
echo -e "  Commits: $(git rev-list --count HEAD)"
echo ""

# Confirm before pushing
echo -e "${YELLOW}[!]${NC} Important: Make sure you have:"
echo "  1. Created the repository on GitHub.com"
echo "  2. Made it empty (no README or .gitignore)"
echo "  3. Have GitHub credentials configured"
echo ""

read -p "Ready to push? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo -e "${YELLOW}[!]${NC} Push cancelled"
    exit 0
fi

# Push to GitHub
echo ""
echo -e "${BLUE}[•]${NC} Pushing to GitHub..."
echo -e "${YELLOW}You may be prompted to enter GitHub credentials${NC}"
echo ""

if git push -u origin main; then
    echo ""
    echo -e "${GREEN}[✓]${NC} Successfully pushed to GitHub!"
    echo ""
    echo -e "${CYAN}${BOLD}Next Steps:${NC}"
    echo -e "  1. Visit: ${GREEN}${REPO_URL%.git}${NC}"
    echo -e "  2. Add topics (security, linux, scanner, etc.)"
    echo -e "  3. Enable Issues & Discussions in Settings"
    echo -e "  4. Create a Release"
    echo -e "  5. Share on social media:"
    echo -e "     Instagram: @h4cker.in, @exp1oit"
    echo -e "     Telegram: @thunderguyind"
    echo ""
else
    echo ""
    echo -e "${RED}[✗]${NC} Push failed!"
    echo -e "${YELLOW}[!]${NC} Make sure:"
    echo "  • Repository exists on GitHub.com"
    echo "  • You have GitHub credentials configured"
    echo "  • Your internet connection is active"
    echo ""
    echo -e "${BLUE}[•]${NC} For help, see: GITHUB_SETUP.md"
    exit 1
fi
