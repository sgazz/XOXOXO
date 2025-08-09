#!/bin/bash

# XO Arena Web Version Deployment Script
# This script prepares the web version for deployment

echo "🚀 Starting XO Arena deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Check if we're in the right directory
if [ ! -f "index.html" ]; then
    print_error "Please run this script from the web-version directory"
    exit 1
fi

print_status "Checking file structure..."

# Check required files
required_files=(
    "index.html"
    "manifest.json"
    "sw.js"
    "robots.txt"
    "sitemap.xml"
    ".htaccess"
    "css/style.css"
    "js/game.js"
    "js/utils/constants.js"
    "js/utils/soundManager.js"
    "js/utils/statistics.js"
    "js/utils/analytics.js"
    "js/components/Board.js"
    "js/components/Timer.js"
    "js/components/ScoreDisplay.js"
    "js/components/AI.js"
    "js/components/SettingsModal.js"
    "js/scenes/BootScene.js"
    "js/scenes/MenuScene.js"
    "js/scenes/GameScene.js"
    "js/scenes/GameOverScene.js"
)

missing_files=()

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    print_error "Missing required files:"
    for file in "${missing_files[@]}"; do
        echo "  - $file"
    done
    exit 1
fi

print_success "All required files found!"

# Create deployment directory
print_status "Creating deployment directory..."
deploy_dir="deploy"
rm -rf "$deploy_dir"
mkdir -p "$deploy_dir"

# Copy files to deployment directory
print_status "Copying files to deployment directory..."

# Copy all files except node_modules and .git
rsync -av --exclude='node_modules' --exclude='.git' --exclude='deploy' --exclude='*.log' . "$deploy_dir/"

print_success "Files copied to deployment directory"

# Optimize files for production
print_status "Optimizing files for production..."

# Minify CSS (if you have a CSS minifier)
# This is a simple example - in production you might use a proper minifier
if command -v cssmin &> /dev/null; then
    print_status "Minifying CSS..."
    cssmin css/style.css > "$deploy_dir/css/style.min.css"
    mv "$deploy_dir/css/style.min.css" "$deploy_dir/css/style.css"
fi

# Create a simple build info file
echo "Build Date: $(date)" > "$deploy_dir/build-info.txt"
echo "Version: 1.0.0" >> "$deploy_dir/build-info.txt"
echo "Environment: Production" >> "$deploy_dir/build-info.txt"

print_success "Build optimization complete!"

# Create deployment package
print_status "Creating deployment package..."
cd "$deploy_dir"
tar -czf "../xo-arena-web-v1.0.0.tar.gz" .
cd ..

print_success "Deployment package created: xo-arena-web-v1.0.0.tar.gz"

# Display deployment instructions
echo ""
echo "🎯 Deployment Instructions:"
echo "=========================="
echo ""
echo "1. For GitHub Pages:"
echo "   - Push the 'deploy' directory contents to your GitHub repository"
echo "   - Enable GitHub Pages in repository settings"
echo "   - Set source to 'main' branch and '/ (root)' folder"
echo ""
echo "2. For Netlify:"
echo "   - Drag and drop the 'deploy' folder to Netlify"
echo "   - Or connect your GitHub repository"
echo ""
echo "3. For Vercel:"
echo "   - Connect your GitHub repository to Vercel"
echo "   - Set build command to: echo 'Static site'"
echo "   - Set output directory to: deploy"
echo ""
echo "4. For traditional hosting:"
echo "   - Upload all files from 'deploy' directory to your web server"
echo "   - Ensure .htaccess is uploaded for Apache servers"
echo ""
echo "5. For local testing:"
echo "   - cd deploy"
echo "   - python3 -m http.server 8000"
echo "   - Open http://localhost:8000"
echo ""

print_success "Deployment preparation complete!"
print_status "Ready to deploy to your chosen platform!"
