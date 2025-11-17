#!/usr/bin/env python3
import re
import os
from pathlib import Path

def fix_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Replace ephemeral: true with flags: MessageFlags.Ephemeral
    content = re.sub(r'ephemeral:\s*true', 'flags: MessageFlags.Ephemeral', content)
    
    # Add MessageFlags to import if not present and ephemeral was found
    if 'ephemeral: true' not in original_content and 'flags: MessageFlags.Ephemeral' in content:
        # Check if MessageFlags is already imported
        if 'MessageFlags' not in content:
            # Add MessageFlags to discord.js import
            content = re.sub(
                r"(from ['\"]discord\.js['\"])",
                r"\1, MessageFlags",
                content,
                count=1
            )
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed: {file_path}")
        return True
    return False

# Find all TypeScript files in src
src_dir = Path('src')
fixed_count = 0

for ts_file in src_dir.rglob('*.ts'):
    if fix_file(ts_file):
        fixed_count += 1

print(f"\nFixed {fixed_count} files")

