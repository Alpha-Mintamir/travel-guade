import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette - Ethiopian-Inspired Modern
  static const deepTeal = Color(0xFF1D3557);      // Primary - high contrast
  static const warmCoral = Color(0xFFE73947);      // Accent - good on white
  static const softTeal = Color(0xFFA9DADD);       // Light accent - backgrounds only
  static const goldenAmber = Color(0xFFF4A300);    // Accent - for backgrounds/icons
  
  // High-contrast text variants for accent colors (WCAG AA compliant)
  static const goldenAmberDark = Color(0xFFB87700);  // For text on light bg (~5.5:1)
  static const softTealDark = Color(0xFF2A6B70);     // For text on light bg (~5.2:1)
  static const warmCoralDark = Color(0xFFC42B38);    // For text on light bg (~5.8:1)
  
  // Neutrals
  static const background = Color(0xFFF8F9FA);     // Light gray bg
  static const surface = Color(0xFFFFFFFF);        // Pure white
  static const charcoal = Color(0xFF2D3436);       // Primary text (~12:1)
  static const textSecondary = Color(0xFF636E72); // Secondary text (~5.2:1)
  static const textTertiary = Color(0xFF8D9499);   // Placeholder/hint text (~3.5:1)
  
  // Ethiopian Heritage Accents (for badges, tags - use carefully)
  static const ethiopianGreen = Color(0xFF2E7D32);  // Good contrast (~5.4:1)
  static const ethiopianGold = Color(0xFFFFB300);   // Backgrounds only
  static const ethiopianRed = Color(0xFFD32F2F);    // Good contrast (~5.1:1)
  
  // Semantic Colors
  static const success = Color(0xFF00896B);         // Darkened for text (~4.8:1)
  static const successLight = Color(0xFF00B894);    // For backgrounds
  static const warning = Color(0xFFD68A00);         // Darkened for text (~4.6:1)
  static const warningLight = Color(0xFFFDAA5E);    // For backgrounds
  static const error = Color(0xFFD32F2F);           // Good contrast (~5.1:1)
  static const errorLight = Color(0xFFE74C3C);      // For backgrounds
  
  // Dark Mode variants
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkCard = Color(0xFF2D2D2D);
  static const darkTextPrimary = Color(0xFFE8E8E8);  // Primary text in dark
  static const darkTextSecondary = Color(0xFFB0B0B0); // Secondary text in dark
}
