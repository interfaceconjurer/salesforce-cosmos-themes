#!/bin/bash

# Image Optimization Script for VS Code Extension
# Resizes to 1200px width and converts to WebP format

set -e  # Exit on any error

RESOURCES_DIR="./resources"
BACKUP_DIR="./resources/originals"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🖼️  VS Code Extension Image Optimizer${NC}"
echo -e "Resizing to 1200px width and converting to WebP format"
echo ""

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo -e "${RED}❌ ImageMagick not found!${NC}"
    echo -e "Install with: ${YELLOW}brew install imagemagick${NC}"
    exit 1
fi

# Check if webp support is available
if ! magick identify -list format | grep -q WEBP; then
    echo -e "${RED}❌ WebP support not found in ImageMagick!${NC}"
    echo -e "Install with: ${YELLOW}brew install webp${NC}"
    exit 1
fi

echo -e "${GREEN}✅ ImageMagick with WebP support found${NC}"
echo ""

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo -e "📁 Created backup directory: ${BACKUP_DIR}"
fi

# Function to optimize image
optimize_image() {
    local filename="$1"
    local input_path="${RESOURCES_DIR}/${filename}"
    local backup_path="${BACKUP_DIR}/${filename}"
    local output_path="${RESOURCES_DIR}/${filename%.*}.webp"
    
    if [ ! -f "$input_path" ]; then
        echo -e "${RED}❌ File not found: $input_path${NC}"
        return 1
    fi
    
    echo -e "🔄 Processing: ${BLUE}$filename${NC}"
    
    # Get original file size
    if [[ "$OSTYPE" == "darwin"* ]]; then
        original_size=$(stat -f%z "$input_path")
    else
        original_size=$(stat -c%s "$input_path")
    fi
    
    echo -e "   📊 Original size: $(numfmt --to=iec-i --suffix=B --format="%.1f" $original_size 2>/dev/null || echo "${original_size} bytes")"
    
    # Create backup if not exists
    if [ ! -f "$backup_path" ]; then
        cp "$input_path" "$backup_path"
        echo -e "   💾 Backup created: $backup_path"
    fi
    
    # Get current dimensions
    dimensions=$(magick identify -format "%wx%h" "$input_path")
    echo -e "   📐 Original dimensions: $dimensions"
    
    # Optimize: resize to 1200px width, maintain aspect ratio, convert to WebP
    magick "$input_path" \
        -resize '1200x>' \
        -quality 85 \
        -define webp:method=6 \
        -define webp:alpha-quality=100 \
        "$output_path"
    
    # Get new file size and dimensions
    if [[ "$OSTYPE" == "darwin"* ]]; then
        new_size=$(stat -f%z "$output_path")
    else
        new_size=$(stat -c%s "$output_path")
    fi
    
    new_dimensions=$(magick identify -format "%wx%h" "$output_path")
    
    # Calculate compression ratio
    reduction=$(echo "scale=1; (($original_size - $new_size) * 100) / $original_size" | bc 2>/dev/null || echo "N/A")
    
    echo -e "   ✨ ${GREEN}Optimized size: $(numfmt --to=iec-i --suffix=B --format="%.1f" $new_size 2>/dev/null || echo "${new_size} bytes")${NC}"
    echo -e "   📐 New dimensions: $new_dimensions"
    echo -e "   📉 Size reduction: ${GREEN}${reduction}%${NC}"
    echo ""
    
    return 0
}

# Process both theme images
echo -e "${YELLOW}📸 Optimizing theme images...${NC}"
echo ""

optimize_image "dark-cosmos.png"
optimize_image "light-cosmos.png"

echo -e "${GREEN}🎉 Image optimization complete!${NC}"
echo ""
echo -e "${BLUE}📝 Next steps:${NC}"
echo "1. Update your README.md to use the new .webp files:"
echo -e "   ${YELLOW}- Change ./resources/theme-image-dark.png to ./resources/theme-image-dark.webp${NC}"
echo -e "   ${YELLOW}- Change ./resources/theme-image-light.png to ./resources/theme-image-light.webp${NC}"
echo ""
echo "2. Test the extension locally to ensure images display correctly"
echo ""
echo "3. Original PNG files are backed up in ${BACKUP_DIR}/"
echo ""
echo -e "${GREEN}💡 Pro tip: WebP images typically load 25-30% faster than PNG!${NC}"
