# Notifications, Alerts & Reminders Color Fixes

## Overview

Fixed color visibility issues on the Notifications, Alerts, and Reminders screens to ensure compatibility with the new light theme.

## Changes Made

### 1. Notifications Screen (`notifications_screen.dart`)

- **AppBar**: Changed background to `AppTheme.primaryColor` (Purple) and text to White.
- **Content**: Changed "Coming Soon" text from White to `AppTheme.textColor` (Dark).

### 2. Alerts Screen (`alerts_screen.dart`)

- **AppBar**: Changed background to Purple and text to White.
- **Empty State**: Changed text from White to Dark.
- **List Items**:
  - Changed container background to White.
  - Changed title text from White to Dark.
  - Changed timestamp text from White/Opacity to Gray.
- **Modal Bottom Sheet**:
  - Changed background to White.
  - Changed title and message text to Dark.
  - Updated buttons for better visibility.

### 3. Reminders Screen (`reminders_screen.dart`)

- **AppBar**: Changed background to Purple and text to White.
- **Empty State**: Changed text from White to Dark.
- **List Items**:
  - Changed container background to White.
  - Changed title text from White to Dark.
  - Changed description text to Gray.
  - Updated date/time text colors.
- **Modal Bottom Sheet**:
  - Changed background to White.
  - Changed title and description text to Dark.

## Result

All three screens now feature a consistent, professional light theme with high readability.
