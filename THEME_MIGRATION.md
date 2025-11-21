# Theme Migration Guide - New Business Color Scheme

## Overview

This document outlines the theme changes made to adapt the Moinc app for a new business with a different color scheme.

## Color Scheme Transformation

### Old Theme (Moinc)

- **Primary Color**: Gold `#D4AF37`
- **Secondary Color**: Navy Blue `#001A36`
- **Background**: Dark Navy `#001A36`
- **Text**: White on dark backgrounds
- **Style**: Dark, premium, gold accents

### New Theme (New Business)

- **Primary Color**: Purple `#7755FF`
- **Secondary Color**: White `#FFFFFF`
- **Background**: White `#FFFFFF`
- **Text**: Dark `#1A1A1A` on light backgrounds
- **Style**: Light, clean, modern

## Detailed Color Mapping

| Element    | Old Color  | New Color   | Hex Code  |
| ---------- | ---------- | ----------- | --------- |
| Primary    | Gold       | Purple      | `#7755FF` |
| Background | Navy Blue  | White       | `#FFFFFF` |
| Cards      | Dark Navy  | White       | `#FFFFFF` |
| Text       | White      | Dark Gray   | `#1A1A1A` |
| Light Text | Light Gray | Medium Gray | `#666666` |
| Borders    | Gold       | Light Gray  | `#E5E5E5` |
| Input Fill | Navy       | White       | `#FFFFFF` |
| AppBar     | Navy       | Purple      | `#7755FF` |
| Divider    | Gray       | Light Gray  | `#E5E5E5` |

## New Colors Added

```dart
static const Color lightGrayColor = Color(0xFFF5F5F5); // Light gray backgrounds
static const Color grayColor = Color(0xFFE5E5E5); // Gray borders
```

## Component Changes

### 1. **Buttons**

- **Primary Button**
  - Background: Purple `#7755FF`
  - Text: White
  - Border Radius: 8px (was 12px)
- **Secondary Button**
  - Background: White
  - Text: Purple
  - Border: Light gray

### 2. **Input Fields**

- Background: White (was navy)
- Border: Light gray `#E5E5E5` (was gold)
- Focused Border: Purple `#7755FF`
- Text: Dark `#1A1A1A` (was white)
- Hint Text: Light gray (was white70)
- Border Radius: 8px (was 12px)

### 3. **Cards**

- Background: White (was dark navy)
- Border: Light gray `#E5E5E5`
- Elevation: 2 (was 0)
- Border Radius: 12px (was 16px)

### 4. **AppBar**

- Background: Purple `#7755FF` (was navy)
- Text: White (was gold)
- Icons: White (was gold)

### 5. **Gradients**

- **Primary Gradient**: Purple to darker purple (was gold gradient)
- **Secondary Gradient**: Light gray to white (was navy gradient)

## Theme Methods

### lightTheme()

Now properly implements a light theme with:

- `Brightness.light` (was `Brightness.dark`)
- White backgrounds
- Dark text on light surfaces
- Purple primary color
- Light gray secondary color

### darkTheme()

Remains unchanged for now (still uses the old dark navy theme)

## Text Styles

All text styles remain the same structure but now render with appropriate colors:

- Dark text `#1A1A1A` on light backgrounds
- Maintained Google Fonts (Poppins)
- Same font sizes and weights

## Migration Impact

### Files Modified

- `/lib/config/theme.dart` - Complete theme overhaul

### Breaking Changes

⚠️ **Visual Breaking Changes**:

- All screens will now have white backgrounds instead of navy
- All text will be dark instead of white
- All buttons will be purple instead of gold
- Input fields will have gray borders instead of gold

### Non-Breaking Changes

✅ **Structure Preserved**:

- All theme method names remain the same
- All color constant names remain the same
- All text style getters remain the same
- No API changes required in consuming code

## Testing Checklist

- [ ] Login screen displays correctly with white background
- [ ] Input fields are readable with dark text
- [ ] Buttons show purple background with white text
- [ ] AppBar shows purple with white icons
- [ ] Cards have subtle shadows and borders
- [ ] Navigation works with new colors
- [ ] Dashboard displays correctly
- [ ] AI Agent screen works with new theme
- [ ] All icons are visible (dark on light)
- [ ] Text contrast is sufficient for readability

## Rollback Instructions

If you need to revert to the old Moinc theme:

1. Change primary color back to gold:

   ```dart
   static const Color primaryColor = Color(0xFFD4AF37);
   ```

2. Change backgrounds back to navy:

   ```dart
   static const Color backgroundColor = Color(0xFF001A36);
   static const Color secondaryColor = Color(0xFF001A36);
   ```

3. Revert other colors to their original navy/gold scheme

## Future Considerations

### Multi-Tenant Support

Consider creating separate theme files for different businesses:

```
/lib/config/
  ├── theme.dart (base theme structure)
  ├── moinc_theme.dart (gold/navy theme)
  └── new_business_theme.dart (purple/white theme)
```

### Environment-Based Themes

Use environment variables or config files to switch themes:

```dart
final theme = Environment.businessName == 'moinc'
  ? MoincTheme.lightTheme()
  : NewBusinessTheme.lightTheme();
```

## Notes

- The dark theme (`darkTheme()`) was not modified and still uses the old color scheme
- Some deprecation warnings exist for `background` and `onBackground` in ColorScheme (Flutter 3.18+)
- Border radius reduced from 12px/16px to 8px/12px for a more modern look
- Card elevation increased from 0 to 2 for better depth perception on white backgrounds

## Summary

The theme has been successfully migrated from a dark navy/gold scheme to a light white/purple scheme, matching the new business requirements. All components maintain their structure while adopting the new color palette.
