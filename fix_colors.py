#!/usr/bin/env python3
"""
Script to automatically fix white text colors in Flutter files for light theme compatibility.
Replaces Colors.white with AppTheme.textColor or AppTheme.lightTextColor based on context.
"""

import os
import re
import sys

# Color replacements
REPLACEMENTS = [
    # Text colors
    (r'color:\s*Colors\.white\b(?!\.)(?![,\)])', 'color: AppTheme.textColor'),
    (r'color:\s*Colors\.white\.withOpacity\(0\.[7-9]\d*\)', 'color: AppTheme.lightTextColor'),
    (r'color:\s*Colors\.white\.withValues\(alpha:\s*0\.[7-9]\d*\)', 'color: AppTheme.lightTextColor'),
    (r'color:\s*Colors\.white70\b', 'color: AppTheme.lightTextColor'),
    
    # TextStyle colors
    (r'TextStyle\(color:\s*Colors\.white\)', 'TextStyle(color: AppTheme.textColor)'),
    (r'TextStyle\(([^)]*),\s*color:\s*Colors\.white\)', r'TextStyle(\1, color: AppTheme.textColor)'),
    (r'TextStyle\(color:\s*Colors\.white,', 'TextStyle(color: AppTheme.textColor,'),
    
    # Icon colors (but not on purple backgrounds)
    (r'Icon\(([^,]+),\s*color:\s*Colors\.white\)', r'Icon(\1, color: AppTheme.textColor)'),
    
    # foregroundColor in buttons (keep white for primary buttons)
    # (r'foregroundColor:\s*Colors\.black\b', 'foregroundColor: Colors.white'),
]

def should_skip_file(filepath):
    """Check if file should be skipped"""
    skip_patterns = [
        'theme.dart',  # Don't modify theme file
        '.g.dart',     # Generated files
        '.freezed.dart',  # Generated files
    ]
    return any(pattern in filepath for pattern in skip_patterns)

def fix_file(filepath):
    """Fix white colors in a single file"""
    if should_skip_file(filepath):
        return False
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        changes_made = False
        
        # Apply all replacements
        for pattern, replacement in REPLACEMENTS:
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                changes_made = True
                content = new_content
        
        # Write back if changes were made
        if changes_made:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Fixed: {filepath}")
            return True
        
        return False
    
    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}")
        return False

def main():
    """Main function to process all Dart files"""
    if len(sys.argv) < 2:
        print("Usage: python3 fix_colors.py <directory>")
        sys.exit(1)
    
    root_dir = sys.argv[1]
    
    if not os.path.exists(root_dir):
        print(f"Error: Directory {root_dir} does not exist")
        sys.exit(1)
    
    print(f"🔍 Scanning {root_dir} for Dart files with white colors...")
    print()
    
    total_files = 0
    fixed_files = 0
    
    # Walk through all Dart files
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                total_files += 1
                
                if fix_file(filepath):
                    fixed_files += 1
    
    print()
    print(f"📊 Summary:")
    print(f"   Total files scanned: {total_files}")
    print(f"   Files fixed: {fixed_files}")
    print(f"   Files unchanged: {total_files - fixed_files}")

if __name__ == '__main__':
    main()
