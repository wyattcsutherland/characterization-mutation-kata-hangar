#!/bin/bash

# Fix Scripts - Line Endings and Permissions
# This script fixes line endings and makes all run-tests scripts executable
# across all implementations in the repository

set -e  # Exit on any error

echo "🔧 Fixing run-tests scripts across all implementations..."

# Function to fix a single script file
fix_script() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "  📝 Fixing: $file"
        
        # Fix line endings (convert Windows CRLF to Unix LF)
        sed -i 's/\r$//' "$file" 2>/dev/null || true
        
        # Make executable
        chmod +x "$file"
    fi
}

# Find and fix all .sh files
echo "� Searching for all .sh files..."
find . -name "*.sh" -type f | while read -r file; do
    fix_script "$file"
done

echo ""

# Find and fix all .ps1 files
echo "📁 Searching for all .ps1 files..."
find . -name "*.ps1" -type f | while read -r file; do
    fix_script "$file"
done

echo ""

# Find and fix all gradlew files
echo "📁 Searching for all gradlew files..."
find . -name "gradlew" -type f | while read -r file; do
    echo "  📝 Fixing Gradle wrapper: $file"
    
    # Fix line endings
    sed -i 's/\r$//' "$file" 2>/dev/null || true
    
    # Make executable
    chmod +x "$file"
    
    echo "     ✅ Fixed Gradle wrapper"
done

echo ""
echo "✅ All script files have been fixed!"
echo "📋 Summary of actions taken:"
echo "   • Fixed line endings (converted CRLF to LF)"
echo "   • Made all script files executable"
echo ""
echo "🚀 All shell scripts in the repository are now ready to run on Linux!"