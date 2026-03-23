#!/bin/bash

# --- Configuration ---
REPO="x0x7F/Kyami"
TAG="v1.0"
# Since you are running inside ~/shwenote_data, 
# the 'books' folder is just 'books'
BASE_DIR="books"

echo "🚀 Starting Master Deployment for $REPO..."

# 1. Initialize Git and Fix Branch
if [ ! -d ".git" ]; then
    git init
    git remote add origin "https://github.com/$REPO.git"
fi
git branch -M main

# 2. Create Required Files
touch .nojekyll

# 3. Sync Web App & Images to Repo
echo "📂 Syncing Web App and Images..."
git add index.html .nojekyll web_data/ a.py a.sh

# Find all covers and add them
# This matches: books/7/images/cover.jpg
find "$BASE_DIR" -name "cover.jpg" -exec git add {} +

git commit -m "Update: Web App and Book Covers"
# Using -f to force overwrite since we re-initialized
git push -u origin main --force

# 4. Create/Check Release
echo "📦 Checking GitHub Release $TAG..."
gh release create $TAG --repo $REPO --title "Kyami Audio Vault" --notes "Audio assets" || echo "Release exists."

# 5. Upload Audio to Release
echo "🎵 Scanning and Uploading Audio..."
find "$BASE_DIR" -name "full_audio.mp3" | while read -r filepath; do
    
    # Correct ID extraction: 
    # filepath looks like: books/7/audio/full_audio.mp3
    # We take the 2nd part of the path
    book_id=$(echo "$filepath" | cut -d'/' -f2)
    target_name="${book_id}.mp3"
    
    echo "📡 Uploading: $target_name"
    
    # Rename via symlink
    ln -sf "$(pwd)/$filepath" "/tmp/$target_name"
    
    # Upload
    gh release upload $TAG "/tmp/$target_name" --repo $REPO --clobber
    
    rm "/tmp/$target_name"
done

echo "✅ ALL DONE!"
