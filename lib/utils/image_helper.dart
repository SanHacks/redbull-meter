import 'package:flutter/material.dart';
import 'dart:io';

/// Helper class for displaying flavor images (both assets and files)
class ImageHelper {
  /// Builds a flavor image widget that handles both asset and file images
  static Widget buildFlavorImage(
    String? imagePath,
    double width,
    double height, {
    bool isActive = true,
    Color? fallbackColor,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: (fallbackColor ?? Colors.green).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.local_drink,
          color: isActive ? (fallbackColor ?? Colors.green) : Colors.grey,
          size: height * 0.5,
        ),
      );
    }

    // Check if it's a file path (user-captured) or asset path
    if (imagePath.startsWith('/') || imagePath.contains('user_flavors')) {
      // It's a file path
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: (fallbackColor ?? Colors.green).withValues(alpha: 0.2),
            child: Icon(
              Icons.local_drink,
              color: isActive ? (fallbackColor ?? Colors.green) : Colors.grey,
              size: height * 0.5,
            ),
          );
        },
      );
    } else {
      // It's an asset path
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: (fallbackColor ?? Colors.green).withValues(alpha: 0.2),
            child: Icon(
              Icons.local_drink,
              color: isActive ? (fallbackColor ?? Colors.green) : Colors.grey,
              size: height * 0.5,
            ),
          );
        },
      );
    }
  }
}
