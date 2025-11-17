#!/bin/bash

# Script pour résoudre les conflits Git
# Usage: ./scripts/fix-git-conflicts.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

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

print_info "Git Conflict Resolver"
echo ""

# Check if in git repo
if [ ! -d .git ]; then
    print_error "Not a git repository"
    exit 1
fi

# Show current status
print_info "Current status:"
git status --short
echo ""

# Ask what to do
echo "Choose an option:"
echo "1) Stash local changes and pull"
echo "2) Discard local changes and pull (WARNING: loses local changes)"
echo "3) Commit local changes first"
echo "4) Cancel"
read -p "Choice [1-4]: " choice

case $choice in
    1)
        print_info "Stashing local changes..."
        git stash push -m "Auto-stash $(date +%Y%m%d_%H%M%S)"
        print_success "Changes stashed"
        
        print_info "Pulling from remote..."
        git pull origin main
        if [ $? -eq 0 ]; then
            print_success "Pull successful"
            print_info "To restore stashed changes: git stash pop"
        else
            print_error "Pull failed"
        fi
        ;;
    2)
        print_warning "Discarding local changes..."
        read -p "Are you sure? This will lose all local changes! (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            git fetch origin
            git reset --hard origin/main
            print_success "Reset to remote branch"
        else
            print_info "Cancelled"
        fi
        ;;
    3)
        print_info "Staging all changes..."
        git add .
        read -p "Enter commit message: " commit_msg
        git commit -m "$commit_msg"
        print_success "Changes committed"
        
        print_info "Pulling from remote..."
        git pull origin main
        if [ $? -eq 0 ]; then
            print_success "Pull successful"
        else
            print_error "Pull failed - merge conflicts need manual resolution"
        fi
        ;;
    4)
        print_info "Cancelled"
        exit 0
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

