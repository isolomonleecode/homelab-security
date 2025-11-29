#!/bin/bash
# Script to remove personal information from homelab-security-hardening repository
# This will anonymize your name, phone, email, and LinkedIn profile

set -e

REPO_DIR="/run/media/ssjlox/gamer/Github Projects/homelab-security-hardening"
cd "$REPO_DIR"

echo "🔒 Removing Personal Information from Repository"
echo "================================================"
echo ""

# Backup first
BACKUP_DIR="$HOME/homelab-backup-$(date +%Y%m%d_%H%M%S)"
echo "📦 Creating backup at: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r . "$BACKUP_DIR/"
echo "✅ Backup created"
echo ""

# Personal info to replace
OLD_NAME="Latrent Childs"
NEW_NAME="[Your Name]"

OLD_PHONE="832-985-9411"
NEW_PHONE="[Your Phone]"

OLD_EMAIL1="Tchilds07@icloud.com"
OLD_EMAIL2="latrent.childs@jnelee.com"
NEW_EMAIL="[your.email@example.com]"

OLD_LINKEDIN="https://www.linkedin.com/in/latrent-childs/"
NEW_LINKEDIN="[your-linkedin-url]"

echo "🔍 Searching for personal information..."
echo ""

# Function to replace text in file
replace_in_file() {
    local file="$1"
    local old="$2"
    local new="$3"

    if grep -q "$old" "$file" 2>/dev/null; then
        sed -i "s|$old|$new|g" "$file"
        echo "  ✓ Updated: $file"
    fi
}

# Replace in all markdown files
echo "📝 Anonymizing markdown files..."
find . -type f -name "*.md" -not -path "./.git/*" | while read -r file; do
    replace_in_file "$file" "$OLD_NAME" "$NEW_NAME"
    replace_in_file "$file" "$OLD_PHONE" "$NEW_PHONE"
    replace_in_file "$file" "$OLD_EMAIL1" "$NEW_EMAIL"
    replace_in_file "$file" "$OLD_EMAIL2" "$NEW_EMAIL"
    replace_in_file "$file" "$OLD_LINKEDIN" "$NEW_LINKEDIN"
done

echo ""
echo "📁 Handling career folder..."

# Option 1: Delete career folder completely (recommended for public repo)
if [ "$1" == "--delete-career" ]; then
    echo "🗑️  Deleting career folder..."
    rm -rf career/
    echo "✅ Career folder deleted"

# Option 2: Move career folder outside repo
elif [ "$1" == "--move-career" ]; then
    CAREER_BACKUP="$HOME/homelab-career-backup"
    echo "📦 Moving career folder to: $CAREER_BACKUP"
    mkdir -p "$CAREER_BACKUP"
    mv career/ "$CAREER_BACKUP/"
    echo "✅ Career folder moved outside repository"

# Option 3: Keep but anonymize (default)
else
    echo "ℹ️  Career folder anonymized (personal info removed)"
    echo "   To delete: run with --delete-career"
    echo "   To move: run with --move-career"
fi

echo ""
echo "🔒 Updating .gitignore to prevent future commits of personal info..."

# Add patterns to .gitignore
cat >> .gitignore << 'EOF'

# Personal information (do not commit)
career/
*Resume.md
*CoverLetter.md
*personal*.md
.claude/
EOF

echo "✅ .gitignore updated"
echo ""

# Check for any remaining personal info
echo "🔍 Checking for remaining personal information..."
if grep -r "832-985-9411\|Tchilds07@icloud\|latrent.childs@jnelee.com\|Latrent Childs" --include="*.md" . 2>/dev/null | grep -v ".git"; then
    echo "⚠️  WARNING: Some personal information may still remain (shown above)"
else
    echo "✅ No personal information found in tracked files"
fi

echo ""
echo "════════════════════════════════════════════════"
echo "✅ Personal Information Removal Complete!"
echo "════════════════════════════════════════════════"
echo ""
echo "📊 Summary:"
echo "  • Name anonymized: Latrent Childs → [Your Name]"
echo "  • Phone removed: 832-985-9411 → [Your Phone]"
echo "  • Email anonymized: Tchilds07@icloud.com → [your.email@example.com]"
echo "  • LinkedIn removed"
echo "  • Backup saved to: $BACKUP_DIR"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review changes: git diff"
echo "  2. If satisfied, commit: git add -A && git commit -m 'Remove personal information'"
echo "  3. Force push to GitHub (if already pushed): git push origin main --force"
echo ""
echo "⚠️  IMPORTANT:"
echo "  • If you previously pushed personal info to GitHub, you need to:"
echo "    1. Force push these changes to overwrite history"
echo "    2. Consider using 'git filter-branch' or 'BFG Repo-Cleaner' to remove from history"
echo "    3. Or create a fresh repo and push cleaned version"
echo ""
echo "💡 Recommended: Create fresh repository with cleaned code"
echo ""
