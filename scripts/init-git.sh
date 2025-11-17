#!/bin/bash

# Script pour initialiser Git et faire le premier push
# Usage: ./scripts/init-git.sh

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/Polosk0/discord.cool.bot.git"

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

# Check if already a git repo
if [ -d .git ]; then
    print_warning "Git repository already initialized"
    
    # Check remote
    CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)
    if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
        print_info "Updating remote URL..."
        git remote set-url origin "$REPO_URL"
        print_success "Remote updated"
    else
        print_info "Remote is already configured correctly"
    fi
else
    print_info "Initializing Git repository..."
    git init
    git remote add origin "$REPO_URL"
    print_success "Git repository initialized"
fi

# Check if .env exists and warn
if [ -f .env ]; then
    if git ls-files --error-unmatch .env &>/dev/null; then
        print_warning ".env is tracked by Git! Removing it..."
        git rm --cached .env
        print_success ".env removed from Git tracking"
    fi
fi

# Add all files
print_info "Adding files to Git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    print_warning "No changes to commit"
else
    print_info "Committing changes..."
    git commit -m "Initial commit: Discord bot with network tools and DDoS capabilities"
    print_success "Changes committed"
    
    # Ask if user wants to push
    read -p "Do you want to push to GitHub? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Pushing to GitHub..."
        git branch -M main
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            print_success "Code pushed to GitHub successfully!"
            print_info "Repository: $REPO_URL"
        else
            print_error "Failed to push. Check your authentication."
            print_info "You may need to set up a Personal Access Token or SSH key"
        fi
    else
        print_info "You can push later with: git push -u origin main"
    fi
fi

print_success "Git setup complete!"

