#!/usr/bin/env python3
"""
Script to download Red Bull energy drink can images from Red Bull's website.
Note: This script is for educational purposes. Ensure you have permission to use these images.

Usage:
    python3 download_redbull_images.py

The script will download Red Bull can images and save them to assets/images/flavors/
"""

import os
import requests
from pathlib import Path
from urllib.parse import urlparse
import time

# Red Bull flavors with their image URLs
# Note: These URLs may need to be updated based on Red Bull's current website structure
RED_BULL_FLAVORS = {
    'redbull-original.webp': 'https://www.redbull.com/images/products/red-bull-original',
    'redbull-sugarfree.webp': 'https://www.redbull.com/images/products/red-bull-sugarfree',
    'redbull-zero.webp': 'https://www.redbull.com/images/products/red-bull-zero',
    'redbull-red-edition.webp': 'https://www.redbull.com/images/products/red-bull-red-edition',
    'redbull-blue-edition.webp': 'https://www.redbull.com/images/products/red-bull-blue-edition',
    'redbull-yellow-edition.webp': 'https://www.redbull.com/images/products/red-bull-yellow-edition',
    'redbull-green-edition.webp': 'https://www.redbull.com/images/products/red-bull-green-edition',
    'redbull-purple-edition.webp': 'https://www.redbull.com/images/products/red-bull-purple-edition',
    'redbull-peach-edition.webp': 'https://www.redbull.com/images/products/red-bull-peach-edition',
    'redbull-summer-edition.webp': 'https://www.redbull.com/images/products/red-bull-summer-edition',
    'redbull-winter-edition.webp': 'https://www.redbull.com/images/products/red-bull-winter-edition',
    'redbull-amber-edition.webp': 'https://www.redbull.com/images/products/red-bull-amber-edition',
}

# Alternative: Direct image URLs (if available)
# You may need to inspect Red Bull's website to find direct image URLs
ALTERNATIVE_URLS = {
    'redbull-original.webp': None,  # Add direct image URLs here
    'redbull-sugarfree.webp': None,
    'redbull-zero.webp': None,
    'redbull-red-edition.webp': None,
    'redbull-blue-edition.webp': None,
    'redbull-yellow-edition.webp': None,
    'redbull-green-edition.webp': None,
    'redbull-purple-edition.webp': None,
    'redbull-peach-edition.webp': None,
    'redbull-summer-edition.webp': None,
    'redbull-winter-edition.webp': None,
    'redbull-amber-edition.webp': None,
}

def download_image(url, filepath):
    """Download an image from a URL and save it to filepath."""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        
        with open(filepath, 'wb') as f:
            f.write(response.content)
        print(f"✓ Downloaded: {filepath.name}")
        return True
    except Exception as e:
        print(f"✗ Failed to download {filepath.name}: {e}")
        return False

def scrape_redbull_site():
    """
    Scrape Red Bull website for product images.
    Note: This is a placeholder. Actual implementation would require:
    1. Parsing HTML/JSON from Red Bull's API or website
    2. Finding product image URLs
    3. Handling authentication/rate limiting if needed
    """
    print("⚠️  Web scraping Red Bull's website requires:")
    print("   1. Inspecting their website structure")
    print("   2. Finding product image endpoints")
    print("   3. Respecting their robots.txt and terms of service")
    print("   4. Obtaining proper permissions if needed")
    print("\n💡 Alternative: Manually download images from Red Bull's website")
    print("   and save them to assets/images/flavors/ with the correct names.")

def main():
    """Main function to download Red Bull images."""
    # Get the project root directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    flavors_dir = project_root / 'assets' / 'images' / 'flavors'
    
    # Create flavors directory if it doesn't exist
    flavors_dir.mkdir(parents=True, exist_ok=True)
    
    print("Red Bull Image Downloader")
    print("=" * 50)
    print(f"Target directory: {flavors_dir}")
    print()
    
    # Check if we have direct image URLs
    has_direct_urls = any(ALTERNATIVE_URLS.values())
    
    if has_direct_urls:
        print("Downloading images from direct URLs...")
        for filename, url in ALTERNATIVE_URLS.items():
            if url:
                filepath = flavors_dir / filename
                if not filepath.exists():
                    download_image(url, filepath)
                    time.sleep(1)  # Be respectful with requests
                else:
                    print(f"⊘ Already exists: {filename}")
    else:
        print("⚠️  No direct image URLs configured.")
        print("\nTo download images:")
        print("1. Visit https://www.redbull.com")
        print("2. Navigate to their products page")
        print("3. Right-click on each Red Bull can image")
        print("4. Save images to assets/images/flavors/ with these names:")
        print()
        for filename in RED_BULL_FLAVORS.keys():
            print(f"   - {filename}")
        print()
        print("Or update ALTERNATIVE_URLS in this script with direct image URLs.")
    
    print("\n" + "=" * 50)
    print("Download complete!")

if __name__ == '__main__':
    main()
