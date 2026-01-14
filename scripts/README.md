# Red Bull Image Download Script

This directory contains scripts to help download Red Bull energy drink can images.

## Legal Notice

⚠️ **IMPORTANT**: Before downloading and using Red Bull images:
1. Check Red Bull's terms of service and brand guidelines
2. Ensure you have permission to use their copyrighted images
3. Consider contacting Red Bull for official media assets
4. Respect copyright laws and intellectual property rights

## Manual Download Instructions

The easiest way to get Red Bull images:

1. Visit [Red Bull's official website](https://www.redbull.com)
2. Navigate to their products/energy drinks section
3. For each flavor, right-click on the can image
4. Save the image to `assets/images/flavors/` with these exact names:
   - `redbull-original.webp`
   - `redbull-sugarfree.webp`
   - `redbull-zero.webp`
   - `redbull-red-edition.webp`
   - `redbull-blue-edition.webp`
   - `redbull-yellow-edition.webp`
   - `redbull-green-edition.webp`
   - `redbull-purple-edition.webp`
   - `redbull-peach-edition.webp`
   - `redbull-summer-edition.webp`
   - `redbull-winter-edition.webp`
   - `redbull-amber-edition.webp`

5. Convert images to WebP format if needed (for better compression):
   ```bash
   # Using ImageMagick
   convert input.png -quality 85 output.webp
   
   # Or using cwebp (from WebP tools)
   cwebp -q 85 input.png -o output.webp
   ```

## Automated Script

The `download_redbull_images.py` script can help automate the process, but you'll need to:
1. Find direct image URLs from Red Bull's website
2. Update the `ALTERNATIVE_URLS` dictionary in the script
3. Run: `python3 scripts/download_redbull_images.py`

## Image Requirements

- Format: WebP (recommended) or PNG
- Recommended size: 500x500px or larger
- Aspect ratio: Square or portrait (can images)
- File size: Keep under 200KB per image for optimal app performance
