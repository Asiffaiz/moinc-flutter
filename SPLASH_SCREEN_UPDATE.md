# Splash Screen Update

## Overview

Updated the splash screen design to use new assets and a responsive layout.

## Changes Made

### 1. Splash Screen (`splash_screen.dart`)

- **Background**: Replaced the gradient container with `assets/images/splash_background.png` using `BoxFit.cover` to fill the screen.
- **Logo**: Replaced the old logo and text with `assets/images/splash_logo.png`.
- **Layout**: Implemented a `Stack` layout with the logo centered and responsive (70% of screen width).
- **Loading Indicator**: Changed the spinner color to `AppTheme.primaryColor` (Purple) for better visibility on the new background.

## Assets Used

- `assets/images/splash_background.png`
- `assets/images/splash_logo.png`

## Result

The splash screen now matches the new design requirements with the correct branding and background.
