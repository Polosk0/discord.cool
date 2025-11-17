#!/bin/bash

# Script to replace all ephemeral: true with flags: MessageFlags.Ephemeral
# and add MessageFlags import where needed

find src -name "*.ts" -type f | while read file; do
    if grep -q "ephemeral: true" "$file"; then
        echo "Fixing $file..."
        
        # Add MessageFlags import if not present
        if ! grep -q "MessageFlags" "$file"; then
            # Find the discord.js import line
            if grep -q "from 'discord.js'" "$file"; then
                sed -i "s/from 'discord.js'/&, MessageFlags/" "$file"
            fi
        fi
        
        # Replace ephemeral: true
        sed -i "s/ephemeral: true/flags: MessageFlags.Ephemeral/g" "$file"
    fi
done

echo "Done!"

